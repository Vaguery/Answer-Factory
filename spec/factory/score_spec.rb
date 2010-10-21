require 'spec_helper'

describe "initialization" do
  it "should change the encoding of the @name attribute to utf-8 if utf-8 is available in the runtime" do
    pending "why?"
    ascii_name = "foo".force_encoding("US-ASCII")
    forced = Score.new(ascii_name, 12, 88)
  end
end