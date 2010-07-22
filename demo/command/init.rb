# encoding: UTF-8
require File.expand_path('../../answer_factory.rb', File.dirname(__FILE__))
require 'yaml'

file = File.expand_path('../database.yaml', File.dirname(__FILE__))
Factory.database YAML.parser.load(File.read(file))
