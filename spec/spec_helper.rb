#encoding: utf-8
$: << File.join(File.dirname(__FILE__), "/../lib") 


require 'spec'
require 'pp'
require 'nudge-gp'
require 'erb'
require 'fakeweb'
require 'couchrest'
require 'json'

include Nudge
include NudgeGP