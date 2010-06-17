require 'factory/schedule'
require 'factory/schedule/item'

Dir.glob('factory/*.rb') {|file| require file }
Dir.glob('factory/*/*.rb') {|file| require file }
Dir.glob('factory/*/*/*.rb') {|file| require file }
