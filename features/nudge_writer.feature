Feature: Nudge Writer
  In order to create new random code
  As a modeler
  I want a machine that generates Answers from a specified distribution

  Scenario: default proportion of blocks, refs, instructions, and values
    Given I have not specified the ratio of blocks:refs:instructions:values
    When I create a NudgeWriter with those settings
    And I use the NudgeWriter to generate 10000 samples
    Then about 25% of the points generated should be block points
    And about 25% of the points generated should be ref points
    And about 25% of the points generated should be instruction points
    And about 25% of the points generated should be value points
    
    
  Scenario: specifying the relative proportion of blocks, refs, instructions, and values
    Given I have specified the ratio of blocks:refs:instructions:values is 1:11:5:3
    When I create a NudgeWriter with those settings
    And I use the NudgeWriter to generate 10000 samples
    Then about 5% of the points generated should be block points
    And about 55% of the points generated should be ref points
    And about 25% of the points generated should be instruction points
    And about 15% of the points generated should be value points
  
  
  Scenario: specifying the instruction set
    Given I have specified the instructions are "[:foo_bar, :foo_baz]"
    When I create a NudgeWriter with those settings
    And I use the NudgeWriter to generate 1000 samples
    Then about 50% of the instructions generated should be "foo_bar"
    And about 50% of the instructions generated should be "foo_baz"  
  
  
  Scenario: specifying program size
    Given context
    When event
    Then outcome
  
  
  