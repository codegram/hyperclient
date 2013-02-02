Feature: Default config
  In order to use HAL JSON apis
  As a user
  I want to make sure the default config is working

  Scenario: Default headers
    Given I use the default hyperclient config
    When I connect with the API
    Then the request should have been sent with the correct JSON headers
