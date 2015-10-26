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


  @api
  Scenario: test-datasets
    Given groups:
      | title    | author | published |
      | Group 01 | Admin  | Yes       |
    Given datasets:
      | title       | author  | description           | publisher | published | resource format  | tags     |
      | Dataset 01  | admin   | Test data collection  | Group 01  | Yes       | csv              | election |
    Given I am on "dataset/dataset-01"
      Then I should see "Dataset 01"
    Given I am on "dataset"
      Then I should see a dataset called "Dataset 01"

  @api
  Scenario: test-resources
    Given groups:
      | title    | author | published |
      | Group 01 | Admin  | Yes       |
    Given datasets:
      | title       | author  | description           | publisher | published | resource format  | tags     |
      | Dataset 01  | admin   | Test data collection  | Group 01  | Yes       | csv              | election |
      | Dataset 02  | admin   | Another  collection   | Group 01  | Yes       | csv              | election |
    Given resources:
      | title        | author  | description    | publisher | published | resource format  | dataset    |
      | Resource 01  | admin   | Test resource  | Group 01  | Yes       | csv              | Dataset 01 |
    Given I am on "dataset/dataset-01"
      Then I should see "Resource 01"

  @api
  Scenario: test-data-stories
    Given data stories:
      | title         | description                           | tags      |
      | Data Story 01 | My story with lots of election data   | election  |
    Given I am on "story/data-story-01"
      Then I should see "Data Story 01"
      And I should see "election"

  @api
  Scenario: test-data-dashboards
    Given data dashboards:
      | title             |
      | Data Dashboard 01 |
    Given I am on "data-dashboard-01"
      Then I should see "Data Dashboard 01"

  @api
  Scenario: test-charts
    Given groups:
      | title    | author | published |
      | Group 01 | Admin  | Yes       |
    Given datasets:
      | title       | author  | description           | publisher | published | resource format  | tags     |
      | Dataset 01  | admin   | Test data collection  | Group 01  | Yes       | csv              | election |
    Given resources:
      | title        | author  | description    | publisher | published | resource format  | dataset    |
      | Resource 01  | admin   | Test resource  | Group 01  | Yes       | csv              | Dataset 01 |
    #
    # TO-DO: add support for feeding in a file to the chart so
    #   it can properly display data
    #
    Given charts:
      | title     | description               | resource        |
      | Chart 01  | Chart of resource 01 data | Resource 01     |
    Given I am logged in as a user with the "administrator" role
    Given I am on "admin/structure/entity-type/visualization/ve_chart"
      Then I should see "Chart 01"