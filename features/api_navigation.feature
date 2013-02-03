Feature: API navigation
  In order to get the data from my API
  As a user
  I want to navigate through the API

  Scenario: Links
    When I connect to the API
    Then I should be able to navigate to posts and authors

  Scenario: Templated links
    Given I connect to the API
    When I search for a post with a templated link
    Then the API should receive the request with all the params

  Scenario: Attributes
    Given I connect to the API
    When I load a single post
    Then I should be able to access it's title and body

  Scenario: Embedded resources
    Given I connect to the API
    When I load a single post
    Then I should also be able to access it's embedded comments
