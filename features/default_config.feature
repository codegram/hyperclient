Feature: Default config
  In order to use HAL JSON apis
  As a user
  I want to make sure the default config is working

  Scenario: JSON headers
    Given I use the default hyperclient config
    When I connect to the API
    Then the request should have been sent with the correct JSON headers

  Scenario: Send JSON data
    Given I use the default hyperclient config
    When I send some data to the API
    Then it should have been encoded as JSON

  Scenario: Parse JSON data
    Given I use the default hyperclient config
    When I get some data from the API
    Then it should have been parsed as JSON
