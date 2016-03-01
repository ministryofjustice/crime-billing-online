#TODO Remove or merge advocate_claims_financial_summary_details.feature and adovcate_claims_financial_summary.feature
@advocate
Feature: Advocate Claims Financial Summary
  Background:
    As an advocate I want to see a financial summary of my claims.

  Scenario: View summary of outstanding claims as an advocate
    Given I am a signed in advocate
      And I have claims
      When I visit the advocates dashboard
     Then I should see my total value of outstanding claims

  @admin
  Scenario: View summary of outstanding claims as an advocate admin
    Given I am a signed in advocate admin
      And my provider has claims
     When I visit the advocates dashboard
     Then I should see the total value of outstanding claims for my provider

  Scenario: View summary of authorised claims as an advocate
    Given I am a signed in advocate
      And I have authorised and part authorised claims
     When I visit the advocates dashboard
     Then I should see my total value of authorised and part authorised claims

  @admin
  Scenario: View summary of authorised claims as an advocate admin
    Given I am a signed in advocate admin
      And my provider has authorised and part authorised claims
     When I visit the advocates dashboard
     Then I should see the total value of authorised and part authorised claims for my provider
