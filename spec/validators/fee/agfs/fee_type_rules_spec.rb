# frozen_string_literal: true

RSpec.describe Fee::AGFS::FeeTypeRules, type: :validator do
  it_behaves_like 'fee_type_rules_creator'
end
