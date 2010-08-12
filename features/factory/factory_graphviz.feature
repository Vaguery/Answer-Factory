Feature: Factory graphviz
  In order to visualize the stocks and flows of a given Factory layout
  As a manager
  I want to be able to draw a dot (graphviz) diagram of the workstations and machines

  Scenario: it should have a connection where a path has been defined
    Given a Workstation called :ws
    And Workstation :ws contains Machine :the_machine
    And Workstation :ws contains Machine :the_other_machine
    And there is a path called :the_path from :the_machine to :the_other_machine
    When I generate the Factory's dot file
    Then the dot file should include an edge from :the_machine to :the_other_machine
  
  
  
