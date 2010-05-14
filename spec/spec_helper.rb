#encoding: utf-8
$: << File.join(File.dirname(__FILE__), "/../lib")
$: << File.join(File.dirname(__FILE__), "/fixtures")

require 'spec'
require 'fakeweb'
require 'couchrest'
require './lib/answer-factory'

include AnswerFactory
include Nudge