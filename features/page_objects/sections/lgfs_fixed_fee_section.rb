class LgfsFixedFeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :quantity_hint, ".quantity_wrapper .govuk-hint"
  element :rate, "input.rate"
  element :total, ".fee-net-amount"
  section :date, CommonDateSection, ".form-date"
end
