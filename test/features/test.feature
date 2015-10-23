Feature: Test

  @javascript
  Scenario: test-submit
    Given I am on the homepage
    And I wait and press "edit-submit--2"

  @api
  Scenario: test-groups
    Given users:
      | name     | mail            | status |
      | teo      | teo@rocks.com   | 1      |
    Given groups:
      | title    | author | published |
      | Group 01 | Admin  | yes       |
    Given group memberships:
      | user  | group     | role on group        | membership status |
      | teo   | Group 01  | administrator member | Active            |
    Given I am on "group/group-01"
      Then I should see "Group 01"
    When I click "Members"
      Then I should see "teo"
      And I should see "administrator member"


  @api @javascript @debugEach
  Scenario: test-datasets
    Given users:
      | name     | mail            | status |
      | teo      | teo@rocks.com   | 1      |
    Given groups:
      | title    | author | published |
      | Group 01 | Admin  | Yes       |
    Given datasets:
      | title       | author  | description           | publisher | published | resource format  | tags     |
      | Dataset 01  | teo     | Test data collection  | Group 01  | Yes       | csv              | election |
      | Dataset 02  | teo     | Another collection    | Group 01  | Yes       | csv              | election |
    Given I am on "dataset/dataset-01"
      Then I should see "Dataset 01"
    Given I am on "dataset"
      Then I should see a dataset called "Dataset 01"
