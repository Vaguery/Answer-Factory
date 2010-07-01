require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'answer'

DataMapper.setup(:default, "mysql://127.0.0.1/my_factory")
DataMapper.finalize
DataMapper.auto_migrate!
