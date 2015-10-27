Feature: Testing storyteller role and permissions

  @api
  Scenario: Can see the administration menu
    Given users:
      | name         | mail                  | status     | roles     |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And I am logged in as "storyteller"
    When I am on the homepage
    Then I should see the administration menu

  @api
  Scenario: Can see administration pages
    Given users:
      | name         | mail                  | status     | roles     |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And I am logged in as "storyteller"
    When I am on "/admin"
    Then I should see "Content"

  @api
  Scenario: Access content overview
    Given users:
      | name         | mail                  | status     | roles     |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And I am logged in as "storyteller"
    When I am on "/admin/content"
    Then I should see "About"

  @api
  Scenario: Create Story Content
    Given users:
      | name         | mail                  | status     | roles       |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And I am logged in as "storyteller"
    When I am on "/node/add/dkan-data-story"
    And I fill in "edit-title" with "Test Story Post"
    And I fill in "body[und][0][value]" with "Test description"
    And I press "Save"
    Then I should see "DKAN Data Story 'Test Story Post' has been created"

  @api
  Scenario: Delete own story content
    Given users:
      | name         | mail                  | status     | roles     |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And data stories:
      | title           | description | author      | status   | tags |
      | Test Story Post | Test post   | storyteller | 1        | election |
    And I am logged in as "storyteller"
    When I am on "story/test-story-post"
    And I click "Edit"
    And I press "Delete"
    And I press "Delete"
    Then I should see "DKAN Data Story Test Story Post has been deleted."

  @api
  Scenario: Edit own story content
    Given users:
      | name         | mail                  | status     | roles     |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And data stories:
      | title           | description | author      | status   | tags   |
      | test Story Post | Test post   | storyteller | 0        | election |
    And I am logged in as "storyteller"
    And I am on "story/test-story-post"
    When I click "Edit"
    And I fill in "body[und][0][value]" with "Test description Update"
    And I press "Save"
    Then I should see "DKAN Data Story Test Story Post has been updated"

  @api @javascript
  Scenario: Use text format filtered_html
    Given users:
      | name         | mail                  | status     | roles     |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And I am logged in as "storyteller"
    When I am on "/node/add/dkan-data-story"
    Then I should have an "html" text format option

  @api
  Scenario: View own unpublished content
    Given users:
      | name         | mail                  | status     | roles     |
      | storyteller  | storyteller@test.com  | 1          | storyteller |
    And data stories:
      | title           | description | author      | status   | tags   |
      | test Story Post | Test post   | storyteller | 0        | election  |
    And I am logged in as "storyteller"
    When I am on "story/test-story-post"
    Then I should see "test Story Post"
