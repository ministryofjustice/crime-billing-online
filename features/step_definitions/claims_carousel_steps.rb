Given(/^(\d+) claims have been assigned to me$/) do |count|
  @claims = []
  count.to_i.times do |n|
    claim = create(:submitted_claim, last_submitted_at: Time.now + n, id: n + 1)
    @case_worker.claims << claim
    @claims << claim
  end
end

Given(/^the claims are sorted most recent first$/) do
  @claims = @claims.sort_by { |c| c.id }.reverse
end

When(/^I visit the caseworkers dashboard$/) do
  visit case_workers_claims_path
end

When(/^I click claim (\d+) in the list$/) do |position|
  all('.js-test-case-number-link')[position.to_i - 1].click
end

Then(/^I should see the text "(.*?)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should (not )?see a link to the next claim$/) do |negate|
  if negate
    expect(page).to_not have_selector('.next-claim')
  else
    expect(page).to have_selector('.next-claim')
  end
end

When(/^I click the next claim link$/) do
  find('.next-claim').click
end

Then(/^I should be on the next claim$/) do
  expect(page.current_path).to eq(case_workers_claim_path(@claims[1].id))
end

Then(/^I should be on the third claim$/) do
  expect(page.current_path).to eq(case_workers_claim_path(@claims[2].id))
end

Then(/^I should be on the last claim$/) do
  expect(page.current_path).to eq(case_workers_claim_path(@claims[-1].id))
end

Then(/^I should be on the claim with id (\d+)$/) do |id|
  expect(page.current_path).to eq(case_workers_claim_path(id))
end
