Feature: Datasets

  Background:
    Given groups:
      | title    | author | published |
      | Group 01 | Admin  | Yes       |
    Given datasets:
      | title       | author  | description                               | publisher | published | resource format  | tags     |
      | Dataset 01  | admin   | Polling places in the state of Wisconsin  | Group 01  | Yes       | csv              | election |
    Given resources:
      | title        | author  | description    | publisher | published | resource format  | dataset    |
      | Resource 01  | admin   | Test resource  | Group 01  | Yes       | csv              | Dataset 01 |

  @api
  Scenario: Sharing the Dataset on Facebook
    Given I am on "/dataset/dataset-01"
    When I click "Facebook"
    Then I should see "Facebook"

  Scenario: Sharing the Dataset on Twitter
    Given I am on "/dataset/dataset-01"
    When I click "Twitter"
    Then I should see "Share a link with your followers"

  Scenario: Seeing the License
    Given I am on "/dataset/dataset-01"
    Then I should see "License not specified"


  Scenario: See Users datasets

  @javascript
  Scenario: Viewing the Dataset
    Given I am on "/dataset/dataset-01"
    Then I should see "Polling places in the state of Wisconsin"
    And I should see "Explore Data"
    And I should see "Dataset Info"
    And I should see "Modified Date"
    And I should see "Identifier"

  @api @javascript @fixme
  Scenario: Create a dataset with a group as an authenticated user
    Given I am logged in as a user with the "authenticated user" role
    And I am on "/node/add/group"
    Then I should see "Create Group"
    When I fill in "title" with "Test Group"
    And I press "Save"
    Then I should see "Test Group has been created"
    Given I am on "/node/add/dataset"
    Then I should see "Create Dataset"
    When I fill in "title" with "Test Dataset"
    And I fill in "body[und][0][value]" with "Test description"
    And I click the chosen field "License Not Specified" and enter "Creative Commons Attribution"
    And I fill in the chosen field "Choose some options" with "Test Group"
    And I press "Next: Add data"
    Then I should see "Test Dataset has been created"
    When I fill in "title" with "Test Resource Link File"
    And I fill in "edit-field-link-remote-file-und-0-filefield-remotefile-url" with "http://demo.getdkan.com/sites/default/files/district_centerpoints_0.csv"
    And I press "edit-another"
    Then I should see "Test Resource Link File has been created"
    And I should see "Add content"
    When I fill in "title" with "Test Resource Upload"
    And I click "Upload a file"
    And I attach the drupal file "Polling_Places_Madison.csv" to "files[field_upload_und_0]"
    And I check "field_upload[und][0][view][grid]"
    And I press "edit-submit"
    And I wait for "Test Resource Upload has been created"
    And I should see "Glendale Elementary School"
    When I click "Test Dataset"
    Then I should see "Test Resource"
    And I should see "Test Group"
    And I should see "Creative Commons Attribution"
    When I click "Test Resource Link File"
    And I wait for "Farah"
    When I am on "dataset/test-dataset"
    Then I should see "Edit"
    And I should see "Add Resource"
    When I am on "/dataset/dataset-01"
    Then I should not see "Edit"
    And I should see "Add Resource"
