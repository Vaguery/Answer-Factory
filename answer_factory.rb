require File.expand_path("../Nudge/nudge", File.dirname(__FILE__))

Dir.glob(File.expand_path("factory/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("factory/*/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("factory/*/*/*.rb", File.dirname(__FILE__))) {|file| require file }

Dir.glob(File.expand_path("nudge/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("nudge/*/*.rb", File.dirname(__FILE__))) {|file| require file }
Dir.glob(File.expand_path("nudge/*/*/*.rb", File.dirname(__FILE__))) {|file| require file }
