ANSWER_FACTORY_ROOT = '..'
require '../answer_factory'

Factory.use(:data_mapper).set_database("127.0.0.1/factory_a")
Factory::Log.stream = true

Factory.file = 'config.rb'

Factory.schedule :generator, :breeder
Factory.run(5)
