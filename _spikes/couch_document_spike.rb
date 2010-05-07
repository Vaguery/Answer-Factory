require 'rubygems'
require 'couchrest'
require 'nudge'
require '../lib/answer-factory'
include Nudge
include AnswerFactory

db = CouchRest.database!("http://127.0.0.1:5984/spike")

answers = 10.times.collect {
  Answer.new(
  NudgeProgram.random,
  tags:[
    "workstation_#{rand(10)}",
    "workstation_#{rand(10)}"
  ],
  :progress => rand(30)
  )}

answers.each {|i| i.scores["error"] = rand()*rand(100)}
answers.each {|i| i.scores["badness"] = rand()*rand(100)-50}

answers.each {|i| puts i.data}

result = db.bulk_save(answers.collect {|i| i.data})
puts result