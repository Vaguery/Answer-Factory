module MysqlAdapter
  Factory.extend MysqlAdapter
  
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
    execute "CREATE TABLE answers (id int(10) unsigned NOT NULL AUTO_INCREMENT, blueprint mediumtext, workstation varchar(50) DEFAULT NULL, machine varchar(50) DEFAULT NULL, language varchar(50) DEFAULT NULL, progress int(11) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
    execute "CREATE TABLE configurations (id int(10) unsigned NOT NULL AUTO_INCREMENT, text mediumtext, created_at datetime DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
    execute "CREATE TABLE schedule_items (id int(10) unsigned NOT NULL AUTO_INCREMENT, workstation varchar(50) DEFAULT NULL, needed int(11) DEFAULT NULL, unit varchar(50) DEFAULT NULL, x int(11) DEFAULT NULL, s float DEFAULT NULL, active int(11) DEFAULT NULL, fresh tinyint(1) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
    execute "CREATE TABLE scores (id int(10) unsigned NOT NULL AUTO_INCREMENT, name varchar(50) DEFAULT NULL, value float DEFAULT NULL, answer_id int(11) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
  end
  
  def zap
    execute "TRUNCATE TABLE answers"
    execute "TRUNCATE TABLE configurations"
    execute "TRUNCATE TABLE schedule_items"
    execute "TRUNCATE TABLE scores"
  end
  
  def save_config (text)
    text.gsub!(/'/,"\'")
    created_at = Time.now.strftime("%F %T")
    
    execute "INSERT INTO configurations (text, created_at) VALUES ('#{text}', '#{created_at}')"
  end
  
  def read_config
    result = select "SELECT text FROM configurations ORDER BY created_at DESC LIMIT 1"
    return *result.fetch_row
  end
  
  def schedule_item (needed, unit, workstation)
    execute "INSERT INTO schedule_items (needed, unit, x, s, active, workstation, fresh) VALUES (#{needed.ceil}, '#{unit}', 0, 0, 0, '#{workstation}', 1)"
  end
  
  def clear_schedule
    execute "TRUNCATE TABLE schedule_items"
  end
  
  def next_item
    result = select "SELECT id, workstation FROM schedule_items WHERE (unit = 'x' AND x + active < needed) OR (unit = 's' AND s < needed) LIMIT 1"
    
    item_id, workstation_name = result.fetch_row
    
    unless item_id
      execute "UPDATE schedule_items SET x = (0), s = (0), active = (0), fresh = (1)"
      retry
    end
    
    execute "UPDATE schedule_items SET active = (active + 1), fresh = (0) WHERE id = #{item_id}"
    
    begin
      time = Time.now
      yield workstation_name.intern
      s = "s + #{Time.now - time}"
      
    #rescue NoMethodError # no such workstation
    #  s = "needed"
    end
    
    execute "UPDATE schedule_items SET x = (x + 1), s = (#{s}), active = (active - 1) WHERE id = #{item_id} AND fresh = 0"
  end
  
  def load_answers (workstation)
    answers_by_machine = Hash.new {|hash,key| hash[key] = [] }
    
    machine_result = select "SELECT DISTINCT machine FROM answers WHERE workstation = '#{workstation.name}'"
    
    while machine_row = machine_result.fetch_row
      if (name = machine_row[0]) == ""
        machine_name = workstation.default_machine_name
      else
        machine_name = name.intern
      end
      
      answers = []
      
      # TODO: use a SQL join to get answers and scores at the same time
      answer_result = select "SELECT * FROM answers WHERE workstation = '#{workstation.name}' AND machine = '#{name}'"
      
      while answer_row = answer_result.fetch_row
        answers.push(answer = Answer.new({}, *answer_row))
        
        score_result = select "SELECT id, name, value FROM scores WHERE answer_id = #{answer.id}"
        
        while score_row = score_result.fetch_row
          score = Score.new({}, *score_row)
          answer.scores[score.name] = score
        end
      end
      
      answers_by_machine[machine_name].concat answers
    end
    
    answers_by_machine
  end
  
  def save_answers (answers)
    answers.each do |answer|
      if answer_id = answer.id
        execute <<-query
          UPDATE answers SET
            blueprint = ('#{answer.blueprint.gsub("'","\'")}'),
            workstation = ('#{answer.workstation}'),
            machine = ('#{answer.machine}'),
            language = ('#{answer.language}'),
            progress = (#{answer.progress})
          WHERE id = #{answer_id}
        query
      else
        execute <<-query
          INSERT INTO answers (blueprint, workstation, machine, language, progress) VALUES 
            ('#{answer.blueprint.gsub(/'/,"\'")}',
            '#{answer.workstation}',
            '#{answer.machine}',
            '#{answer.language}',
            #{answer.progress})
        query
        
        answer_id = @mysql.insert_id
      end
      
      answer.scores.each do |name, score|
        if score_id = score.id
          execute <<-query
            UPDATE scores SET
              name = ('#{name}'),
              value = (#{score.value}),
              answer_id = (#{answer_id})
            WHERE id = #{score_id}
          query
        else
          execute <<-query
            INSERT INTO scores (name, value, answer_id) VALUES (
              '#{name}',
              #{score.value},
              #{answer_id})
          query
        end
      end
    end
  end
  
  def destroy_answers (answers)
    ids = answers.collect do |answer|
      answer.id
    end.compact.join(", ")
    
    execute "DELETE FROM answers WHERE id IN (#{ids})"
    execute "DELETE FROM scores WHERE answer_id IN (#{ids})"
  end
end
