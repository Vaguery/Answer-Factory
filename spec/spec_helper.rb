#encoding: utf-8
$: << File.join(File.dirname(__FILE__), "/../lib") 

require 'spec'
require 'fakeweb'
require 'couchrest'
require './lib/answer-factory'

include AnswerFactory
include Nudge