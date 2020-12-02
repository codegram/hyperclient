Feature: API navigation
  In order to get the data from my API
  As a user
  I want to navigate through the API

  Scenario: Links
    When I connect to the API
    Then I should be able to navigate to posts and authors

  Scenario: Links
    When I connect to the API
    Then I should be able to paginate posts
    Then I should be able to paginate authors

  Scenario: Templated links
    Given I connect to the API
    When I search for a post with a templated link
    Then the API should receive the request with all the params

  Scenario: Templated links with multiple values
    Given I connect to the API
    When I search for posts by tag with a templated link
    Then the API should receive the request for posts by tag with all the params

  Scenario: Attributes
    Given I connect to the API
    When I load a single post
    Then I should be able to access it's title and body

  Scenario: Embedded resources
    Given I connect to the API
    When I load a single post
    Then I should also be able to access it's embedded comments

  Scenario: Navigation links
    When I connect to the API
    Then I should be able to navigate to next page
    Then I should be able to navigate to next page without links

  Scenario: Counts
    When I connect to the API
    Then I should be able to count embedded items
    Then I should be able to iterate over embedded items
