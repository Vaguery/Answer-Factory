Feature: Flow meter
  In order to control the dynamics of answers flowing through the Factory
  As a manager
  I want to know how many answers go into and out of a machine per step

  Scenario: when the Factory is running, I should be able to see the history of Answer flows  
    Given a Workstation called :ws
    And Workstation :ws contains Machine :the_machine
    And Workstation :ws contains Machine :the_other_machine
    And there is a path called :the_path from :the_machine to :the_other_machine
    And :the_machine sends 2 Answers to :the_path for every 1 that comes in
    And there are 100 Answers in :the_machine
    When I run :the_machine
    Then the workstation should assign 200 Answers to :the_other_machine
    And the flow meter in :the_machine should read "2.0" 
  
  
