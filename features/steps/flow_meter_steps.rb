#encoding: utf-8

Given /^a Workstation called :([a-zA-Z_]+)$/ do |workstation|
  @test_workstation = Workstation.new(workstation.intern)
  @test_workstation.instance_variable_set(:@answers_by_machine, {})
end

Given /^Workstation :([a-zA-Z_]+) contains Machine :([a-zA-Z_]+)$/ do |workstation_name, machine_name|
  @machines ||= {}
  @machines[machine_name.intern] = Machine.new(machine_name.intern, @test_workstation)
  @test_workstation.instance_variable_get(:@answers_by_machine)[machine_name.intern] = []
end

Given /^there is a path called :([a-zA-Z_]+) from :([a-zA-Z_]+) to :([a-zA-Z_]+)$/ do |pathname, machine_1, machine_2|
  @machines[machine_1.intern].path[pathname.intern] =
    @test_workstation.instance_variable_get(:@name), machine_2.intern
end

Given /^:([a-zA-Z_]+) sends (\d+) Answers to :([a-zA-Z_]+) for every (\d+) that comes in$/ do |machine_1, output, pathname, input|
  m1 = @machines[machine_1.intern]
  
  m1.output = output.to_i
  m1.input = input.to_i
  m1.pathname = pathname.intern
  
  def m1.process (answers)
    return {@pathname => (answers * (@output/@input))}
  end
end


Given /^there are (\d+) Answers in :([a-zA-Z_]+)$/ do |answer_count, machine|
  @test_workstation.instance_variable_get(:@answers_by_machine)[machine.intern] = [Answer.new("ref x", "nudge")] * 100
end


When /^I run :([a-zA-Z_]+)$/ do |machine|
  @machines[machine.intern].run
end

Then /^the workstation should assign (\d+) Answers to :([a-zA-Z_]+)$/ do |how_many, machine|
  @test_workstation.instance_variable_get(:@answers_by_machine)[machine.intern].length.should == how_many.to_i
end


Then /^the average gain in :([a-zA-Z_]+) for :([a-zA-Z_]+) should read "([^"]*)"$/ do |machine, pathname, reading|
  @machines[machine.intern].average_gain(pathname.intern).should == reading.to_f
end