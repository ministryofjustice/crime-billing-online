@stub_s3_upload

@wip
Feature: Advocate new claim
  Background:
    Given certification types are seeded

  Scenario: Fill in claim form and submit to LAA
    Given I am a signed in advocate
      And There are case types in place
      And I am on the new claim page
     When I fill in the claim details
      And I submit to LAA
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit
     Then I should be redirected to the claim confirmation page
      And I should see the claim totals
      And the claim should be in a "submitted" state

  Scenario: Try to submit a zero value claim
    Given I am a signed in advocate
      And There are case types in place
      And I am on the new claim page
     When I fill in the claim details but add no fees or expenses
      And I submit to LAA
     Then I should see errors

  Scenario: Fill in claim form and submit invalid or incomplete claim to LAA
    Given I am a signed in advocate
      And I am on the new claim page
      And I submit to LAA
     Then I should see errors
      And no claim should be submitted

  Scenario: Clear claim form
    Given I am a signed in advocate
      And There are case types in place
      And I am on the new claim page
     When I fill in the claim details
      And I clear the form
     Then I should be redirected to the new claim page

  @javascript @webmock_allow_localhost_connect
  Scenario: Add mulitple defendants to a new claim
    Given I am a signed in advocate
      And I am on the new claim page
     When I click Add another defendant
     Then I see 2 defendant sections

  @javascript @webmock_allow_localhost_connect
  Scenario: Add and remove defendants from a claim
    Given I am a signed in advocate
      And I am on the new claim page
     When I click Add another defendant
     Then I see 2 defendant sections
     When I choose to remove the additional defendant
     Then I see 1 defendant section

  @javascript @webmock_allow_localhost_connect
  Scenario: Add and remove rep orders for a single defendant
    Given I am a signed in advocate
      And I am on the new claim page
     When I click Add Another Representation Order
     Then I see 2 fields for adding a rep order
     When I choose to remove the additional rep order
    Then I see 1 field for adding a rep order

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Add fees with dates attended then remove fee
    Given I am a signed in advocate
      And a claim exists with state "draft"
      And There are case types in place
      And I update the claim to be of casetype <case_type>
      And I have one fee of type <fee_type>
      And I have <dates_attended_count> dates attended for my one fee
     Then the dates attended are saved for <fee_type>
     When I am on the claim edit page
     Then I should see <dates_attended_count> dates attended fields amongst <fee_type> fees
     When I click remove fee for <fee_type>
      And I save to drafts
     When I am on the claim edit page
     Then I should not see any dates attended fields for <fee_type> fees
      And the dates attended are not saved for <fee_type>

  Examples:
    | case_type                   | dates_attended_count | fee_type |
    | "Cracked Trial"             |    2                 |  "misc"  |
    | "Appeal against conviction" |    3                 |  "fixed" |

  Scenario: Submit valid draft claim to LAA
    Given I am a signed in advocate
      And a claim exists with state "draft"
     When I am on the claim edit page
      And I submit to LAA
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit
     Then I should be on the claim confirmation page
      And the claim should be in state "submitted"

  Scenario: Attempt to submit invalid draft claim to LAA
    Given I am a signed in advocate
      And a claim exists with state "draft"
     When I am on the claim edit page
      And I make the claim invalid
      And I submit to LAA
     Then I should see errors
      And the claim should be in state "draft"

  Scenario: Edit existing submitted claim
    Given I am a signed in advocate
      And a claim exists with state "submitted"
     When I am on the claim edit page
      And I change the case number
      And I submit to LAA
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit
     Then I should be on the claim confirmation page
      And the claim should be in state "submitted"
      And the case number should reflect the change

  Scenario: Admin specifies advocate name
    Given I am a signed in advocate admin
      And There are case types in place
      And There are other advocates in my provider
      And I am on the new claim page
     Then I can view a select of all advocates in my provider
     When I select Advocate name "Doe, John: AC135"
      And I fill in the claim details
      And I submit to LAA
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit
     Then I should be redirected to the claim confirmation page
      And I should see the claim totals

  Scenario: Admin fails to specify advocate name
    Given I am a signed in advocate admin
      And There are case types in place
      And There are basic and non-basic fee types
      And I am on the new claim page
      And I fill in the claim details
      And I submit to LAA
     Then I should be redirected back to the claim form with error

  Scenario: Add Fixed Fee type
    Given I am a signed in advocate
      And There are case types in place
      And I am on the new claim page
     When I fill in the claim details
      And I select a Case Type of "Fixed fee"
      And I add a fixed fee
      And I submit to LAA
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit
     Then I should be redirected to the claim confirmation page
      And I should see the claim totals accounting for only the fixed fee

  Scenario: Add Miscellaneous Fee type
    Given I am a signed in advocate
      And There are case types in place
      And I am on the new claim page
     When I fill in the claim details
      And I add a miscellaneous fee
      And I submit to LAA
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit
     Then I should be redirected to the claim confirmation page
      And I should see the claim totals accounting for the miscellaneous fee

  Scenario: Fixed Fee case type does not save Initial Fees
     Given I am a signed in advocate
       And There are case types in place
       And I am on the new claim page
      When I fill in the claim details
       And I fill in a Miscellaneous Fee
       And I select a Case Type of "Fixed fee"
       And I submit to LAA
      Then There should not be any Initial Fees saved
       And There should be a Miscellaneous Fee Saved

  Scenario: Non-Fixed Fee case type does not save Fixed Fees
     Given I am a signed in advocate
       And There are case types in place
       And I am on the new claim page
      When I fill in the claim details
       And I fill in a Fixed Fee
       And I select a Case Type of "Trial"
       And I submit to LAA
      Then There should not be any Fixed Fees saved

  Scenario: Edit existing non-Fixed case type to be Fixed
    Given I am a signed in advocate
      And There are case types in place
      And a non-fixed-fee claim exists with basic and miscellaneous fees
     When I am on the claim edit page
      And I select a Case Type of "Fixed fee"
      And I submit to LAA
     Then There should not be any Initial Fees saved
      And There should be a Miscellaneous Fee Saved

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Daily attendance fees derived from actual trial length
  Given I am a signed in advocate
    And There are case types in place
    And I am on the new claim page with Daily Attendance Fees in place
    And I select2 a Case Type of "Trial"
    And I fill in actual trial length with <actual_trial_length>
   Then The daily attendance fields should have quantities <daf_quantity>, <dah_quantity>, <daj_quantity>

  Examples:
    | actual_trial_length         | daf_quantity | dah_quantity | daj_quantity |
    | 1                           | 0            | 0            | 0            |
    | 2                           | 0            | 0            | 0            |
    | 3                           | 1            | 0            | 0            |
    | 40                          | 38           | 0            | 0            |
    | 41                          | 38           | 1            | 0            |
    | 50                          | 38           | 10           | 0            |
    | 51                          | 38           | 10           | 1            |
    | 60                          | 38           | 10           | 10           |
    | 70                          | 38           | 10           | 20           |

  Scenario: Uncalculated fees (PPE and NPW) accepts total amount only
    Given I am a signed in advocate
      And There are case types in place
      And There are PPE and NPW fees in place
      And I am on the new claim page
     When I fill in the claim details but add no fees or expenses
      And I fill in quantity 2 and amount 25 for "PPE"
      And I fill in quantity 1 and amount 25 for "NPW"
      And I submit to LAA
     Then The total claimed should equal 50
