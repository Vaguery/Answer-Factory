# encoding: UTF-8
module MysqlAdapter
  require 'rubygems'
  require 'mysql'
  
  Factory::Infinity = 3e+38
  
  def set_database (db)
    @mysql = Mysql.connect(db['host'], db['user'], db['password'], db['name'], db['port'], db['socket'])
    @mysql.query_with_result = false
  end
  
  def execute (query)
    @mysql.query(query) unless query.empty?
  end
  
  def select (query)
    @mysql.query_with_result = true
    result = execute(query)
    @mysql.query_with_result = false
    result
  end
  
  def migrate
    execute "CREATE TABLE answers (id int(10) unsigned NOT NULL AUTO_INCREMENT, blueprint mediumtext, location varchar(100) DEFAULT NULL, language varchar(50) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
    execute "CREATE TABLE scores (id int(10) unsigned NOT NULL AUTO_INCREMENT, name varchar(50) DEFAULT NULL, value float DEFAULT NULL, answer_id int(11) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
  end
  
  def zap
    execute "TRUNCATE TABLE answers"
    execute "TRUNCATE TABLE scores"
  end
  
  def load_answers (location, load_scores)
    load_scores ? load_answers_with_scores(location) : load_answers_without_scores(location)
  end
  
  def load_answers_without_scores (location)
    result = select <<-query
      SELECT id, blueprint, language
      FROM answers
      WHERE location = '#{location}'
    query
    
    answers = []
    
    while row = result.fetch_row
      answer = Answer.new(row[1], row[2])
      answer.instance_variable_set(:@id, row[0])
      answers << answer
    end
    
    answers
  end
  
  def load_answers_with_scores (location)
    result = select <<-query
      SELECT answers.id, answers.blueprint, answers.language, scores.id, scores.name, scores.value
      FROM answers
      LEFT OUTER JOIN scores
      ON answers.id = scores.answer_id
      WHERE location = '#{location}'
      ORDER BY answers.id ASC
    query
    
    answers = []
    last_seen_answer_id = 0
    
    # each row is an answer (possibly duplicate) with 0 or 1 associated scores
    while row = result.fetch_row
      # add an answer if the row contains an answer that hasn't been seen
      if row[0] != last_seen_answer_id
        answer = Answer.new(row[1], row[2])
        answer.instance_variable_set(:@id, last_seen_answer_id = row[0])
        answers << answer
      end
      
      # add a score if the row contains a score
      if score_id = row[3]
        score = Score.new(row[4], row[5], answer.id)
        answer.instance_variable_get(:@scores)[row[4].to_sym] = score
      end
    end
    
    answers
  end
  
  def save_answers (answers)
    return if answers.empty?
    
    inserts = []
    discards = []
    
    answers.each do |answer|
      if answer.location.to_s == "discard"
        discards << answer.id if answer.id
        next
      end
      
      inserts << "(#{answer.id || :NULL},'#{answer.blueprint.gsub(/'/,"\'")}','#{answer.language}','#{answer.location}')"
    end
    
    unless discards.empty?
      ids = discards.join(",")
      execute "DELETE FROM answers WHERE id IN (#{ids})"
      execute "DELETE FROM scores WHERE answer_id IN (#{ids})"
    end
    
    i = 0
    
    while i < inserts.length
      start_index = i
      
      inserts[i..-1].inject(0) do |query_length, string|
        break if (query_length += string.length + 1) > 900000
        i += 1
        query_length
      end
      
      insert_string = inserts[start_index...i].join(",")
      
      execute "REPLACE INTO answers (id, blueprint, language, location) VALUES #{insert_string}"
    end
  end
  
  def save_scores (scores)
    return if scores.empty?
    
    inserts = []
    
    scores.each do |score|
      inserts << "('#{score.name}','#{score.value}','#{score.answer_id}')"
    end
    
    execute "TRUNCATE TABLE scores"
    execute "INSERT INTO scores (name, value, answer_id) VALUES #{inserts.join(",")}"
  end
end
