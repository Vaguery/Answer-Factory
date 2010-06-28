class Factory
  require 'rubygems'
  require 'dm-core'
  require 'dm-migrations'
  require 'database/data_mapper/score'
  require 'database/data_mapper/answer'
  
  def Factory.set_database (address)
    DataMapper.setup(:default, "mysql://#{address}")
    DataMapper.finalize
  end
end
