require 'rubygems'
require 'couchrest'
require 'nudge'
require '../lib/answer-factory'
include Nudge
include AnswerFactory

db = CouchRest.database!("http://127.0.0.1:5984/spike_db")

answers = 10.times.collect {Answer.new(NudgeProgram.random, tags:["workstation_#{rand(10)}", "workstation_#{rand(10)}"])}

answers.each {|i| i.scores["error"] = rand()*rand(100)}
answers.each {|i| i.scores["badness"] = rand()*rand(100)-50}

result = db.bulk_save(answers.collect {|i| i.data})
puts result