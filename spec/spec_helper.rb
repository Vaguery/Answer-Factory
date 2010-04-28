#encoding: utf-8
$: << File.join(File.dirname(__FILE__), "/../lib") 


require 'spec'
require 'pp'
require 'answer-factory'
require 'erb'
require 'fakeweb'
require 'couchrest'
require 'json'

include Nudge
include AnswerFactory