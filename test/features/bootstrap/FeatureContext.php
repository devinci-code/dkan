<?php

use Drupal\DrupalExtension\Context\RawDrupalContext;
use Behat\Behat\Context\SnippetAcceptingContext;
use Behat\Gherkin\Node\PyStringNode;
use Behat\Gherkin\Node\TableNode;
use WebDriver\Key;

/**
 * Defines application features from the specific context.
 */
class FeatureContext extends RawDrupalContext implements SnippetAcceptingContext
{

    /**
     * @Given /^I scroll to the top$/
     */
    public function iScrollToTheTop() {
      $driver = $this->getSession()->getDriver();
      // Wait two seconds for admin menu if using js.
      if ($driver instanceof Selenium2Driver) {
        $element = $driver.findElement(By.id("header"));
        $actions = new Actions($driver);
        $actions.moveToElement($element);
        // actions.click();
        $actions.perform();
      }
    }

    /**
     * @When /^I switch to the frame "([^"]*)"$/
     */
    public function iSwitchToTheFrame($frame) {
      $this->getSession()->switchToIFrame($frame);
    }

    /**
     * @Then /^I should see the "([^"]*)" element in the "([^"]*)" region$/
     */
    public function assertRegionElement($tag, $region) {
      $regionObj = $this->getMainContext()->getRegion($region);
      $elements = $regionObj->findAll('css', $tag);
      if (!empty($elements)) {
        return;
      }
      throw new \Exception(sprintf('The element "%s" was not found in the "%s" region on the page %s', $tag, $region, $this->getSession()->getCurrentUrl()));
    }

    /**
     * @Given /^I switch out of all frames$/
     */
    public function iSwitchOutOfAllFrames() {
      $this->getSession()->switchToIFrame();
    }

    /**
     * @Then /^I wait for the dialog box to appear$/
     */
    public function iWaitForTheDialogBoxToAppear()
    {
        $this->getSession()->wait(2000, "jQuery('#user-login-dialog').children().length > 0");
    }

    /**
     * @Then the Dataset search updates behind the scenes
     */
    public function theDatasetSearchUpdatesBehindTheScenes()
    {
      $index = search_api_index_load('datasets');
      $items =  search_api_get_items_to_index($index);
      search_api_index_specific_items($index, $items);
    }

    /**
     * Selects option in select field with specified by node title.
     *
     * @When /^(?:|I )select node named "(?P<option>(?:[^"]|\\")*)" from "(?P<select>(?:[^"]|\\")*)"$/
     */
    public function selectNodeOption($select, $option)
    {
        $this->assertDrushCommandWithArgument('php-eval', "\"return db_query('SELECT nid FROM node WHERE title = \'$option\'')->fetchField();\"");
        $option = $this->readDrushOutput();
        $option = trim(str_replace(array("'"), "", $option));
        $select = $this->fixStepArgument($select);
        $option = $this->fixStepArgument($option);
        $this->getSession()->getPage()->selectFieldOption($select, $option);
    }

    /**
     * @Given /^I am a "([^"]*)" of the group "([^"]*)"$/
     */
    public function iAmAMemberOfTheGroup($role, $group_name) {
      $nid = db_query('SELECT nid FROM node WHERE title = :group_name', array(':group_name' =>  $group_name))->fetchField();

      if ($account = $this->getCurrentUser()) {
        og_group('node', $nid, array(
          "entity type" => "user",
          "entity" => $account,
          "membership type" => OG_MEMBERSHIP_TYPE_DEFAULT,
        ));
      }
      else {
        throw new \InvalidArgumentException(sprintf('Could not find current user'));
      }

    }

    /**
     * Properly inputs item in field rendered by Chosen.js.
     *
     *
     * @Given /^I fill in the chosen field "([^"]*)" with "([^"]*)"$/
     */
    public function iFillInTheChosenFieldWith($field, $value) {
      $session = $this->getSession();
      $page = $session->getPage();
      $xpath = $page->find('xpath', '//input[@value="' . $field . '"]');
      $field = $this->fixStepArgument($field);
      $value = $this->fixStepArgument($value);
      // Focus means autocoplete will actually show up.
      $this->getSession()->getDriver()->focus('//input[@value="' . $field . '"]');
      //$page->fillField($field, $value);
      $this->iWaitForSeconds(1);
      // Selects the first dropdown since there is no id or other way to
      // reference the desired entry.
      $title = $session->getPage()->find(
          'xpath',
          $session->getSelectorsHandler()->selectorToXpath('xpath', '//li[.="' . $value . '"]')

      );
      $title->click();
    }

   /**
    * @Given /^I click the chosen field "([^"]*)" and enter "([^"]*)"$/
    */
    public function iClickTheChosenFieldAndEnter($field, $value) {
      $session = $this->getSession();
      $page = $session->getPage();
      $field = $this->fixStepArgument($field);
      $value = $this->fixStepArgument($value);
      // Click chosen field.
      $field_click = $session->getPage()->find(
          'xpath',
          $session->getSelectorsHandler()->selectorToXpath('xpath', '//span[.="' . $field . '"]')

      );
      $field_click->click();
      $this->iWaitForSeconds(1);
      // Click value that now appears.
      $title = $session->getPage()->find(
          'xpath',
          $session->getSelectorsHandler()->selectorToXpath('xpath', '//li[.="' . $value . '"]')

      );
      $title->click();
    }

    /**
     * Click some text.
     *
     * @When /^I click on the text "([^"]*)"$/
     */
    public function iClickOnTheText($text) {
      $session = $this->getSession();
      $element = $session->getPage()->find(
        'xpath',
        $session->getSelectorsHandler()->selectorToXpath('xpath',
          '//*[contains(text(), "' . $text . '")]')
      );
      if (NULL === $element) {
        throw new \InvalidArgumentException(sprintf('Cannot find text: "%s"', $text));
      }
      $element->click();
    }

    /**
     * Click on map icon as identified by its z-index.
     *
     * @Given /^I click map icon number "([^"]*)"$/
     */
    public function iClickMapIcon($num) {
      $session = $this->getSession();
      $element = $session->getPage()->find(
          'xpath',
          $session->getSelectorsHandler()->selectorToXpath(
            'xpath',
            '//div[contains(@class, "leaflet-marker-pane")]//img[' . $num . ']'
          )
      );
      if (null === $element) {
          throw new \InvalidArgumentException(sprintf('Cannot find map icon: "%s"', $num));
      }
      $element->click();
    }

    /**
     * Copy of "I fill in" but doesn't escape "(".
     *
     * When using "I fill in" it escaped autocomplete fields node id. Just using
     * the title wouldn't work. The following focuses on the field and selects
     * the first dropdown.
     *
     * @Given /^I fill in the autocomplete field "([^"]*)" with "([^"]*)"$/
     */
    public function iFillInTheAutoFieldWith($field, $value) {
      $session = $this->getSession();
      $field = $this->fixStepArgument($field);
      $value = $this->fixStepArgument($value);
      $input_title = $session->getPage()->find(
          'xpath',
          $session->getSelectorsHandler()->selectorToXpath('xpath', '//input[@value="' . $field . '"]')

      );
      $input_title->click();
      $this->iWaitForSeconds(2);
      // Selects the first dropdown since there is no id or other way to
      // reference the desired entry.
      $title = $session->getPage()->find(
          'xpath',
          $session->getSelectorsHandler()->selectorToXpath('xpath', '//li[.="' . $value . '"]')

      );
      $title->click();
    }

    /**
     * @Given /^I empty the field "([^"]*)"$/
     */
    public function iEmptyTheField($locator) {
      $session = $this->getSession();
      $page = $session->getPage();
      $field = $page->findField($locator);

      if (null === $field) {
          throw new ElementNotFoundException(
              $this->getSession(), 'form field', 'id|name|label|value', $locator
          );
      }

      $field->setValue("");
    }

    /**
     * Wait for the given number of seconds. ONLY USE FOR DEBUGGING!
     *
     * @Given /^I wait for "([^"]*)" seconds$/
     */
    public function iWaitForSeconds($arg1) {
      sleep($arg1);
    }

    /**
     * Check toolbar if this->user isn't working.
     */
    public function getCurrentUser() {
      if ($this->user) {
        return $this->user;
      }
      $session = $this->getSession();
      $page = $session->getPage();
      $xpath = $page->find('xpath', "//div[@class='content']/span[@class='links']/a[1]");
      $userName = $xpath->getText();
      $uid = db_query('SELECT uid FROM users WHERE name = :user_name', array(':user_name' =>  $userName))->fetchField();
      if ($uid && $user = user_load($uid)) {
        return $user;
      }
      return FALSE;
    }

    /************************************/
    /* DATA DASHBOARDS                  */
    /************************************/

    /**
     * @Given data_dashboards:
     */
    public function addDataDashboard(TableNode $data_dashboards_table) {

      // Map readable field names to drupal field names.
      $field_map = array(
        'title' => 'title',
      );

      foreach ($data_dashboards_table->getHash() as $data_dashboards_hash) {

        $node = new stdClass();
        $node->type = 'data_dashboard';

        foreach($data_dashboards_hash as $field => $value) {

          if(isset($field_map[$field])) {
            $drupal_field = $field_map[$field];
            $node->$drupal_field = $value;
          }
          else {
            throw new Exception(sprintf("Data Dashboard field %s doesn't exist, or hasn't been mapped. See FeatureContext::addDataDashboard for mappings.", $field));
          }
        }
        $created_node = $this->getDriver()->createNode($node);
        // Add the created node to the data dashboards array.
        $this->data_dashboards[$created_node->nid] = $created_node;
      }
    }

    /**
     * Clean up generated content.
     */
    public function afterScenario($event) {

      parent::afterScenario($event);

      if (!empty($this->data_dashboards)) {
        foreach ($this->data_dashboards as $data_dashboard_id => $data_dashboard) {
          $this->getDriver()->nodeDelete($data_dashboard);
        }
      }
    }
}
