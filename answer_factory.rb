# encoding: UTF-8
require File.expand_path("../Nudge/nudge", File.dirname(__FILE__))

Dir.glob(File.expand_path("factory/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("built-in/languages/*/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("built-in/machines/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("built-in/scorers/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("built-in/workstations/*.rb", File.dirname(__FILE__))) {|file| require file }
