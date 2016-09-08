Given(/^The timed retention banner feature flag is enabled$/) do
  allow(Settings).to receive(:timed_retention_banner_enabled?).and_return(true)
end

And(/^The timed retention banner (is|is not) visible$/) do |visibility|
  visible = visibility == 'is'
  expect(page).to have_selector('div.js-callout-banner[data-setting=timed_retention_banner_seen]', visible: visible)
end
