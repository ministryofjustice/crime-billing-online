require 'rails_helper'

LITIGATOR_FINAL_VALIDATE_ENDPOINT = ClaimApiEndpoints.for(:final).validate

RSpec.describe API::V1::ExternalUsers::Claims::FinalClaim do
  include Rack::Test::Methods
  include ApiSpecHelper

  let(:claim_class)     { Claim::LitigatorClaim }
  let!(:provider)       { create(:provider, :lgfs) }
  let!(:vendor)         { create(:external_user, :admin, provider:) }
  let!(:litigator)      { create(:external_user, :litigator, provider:) }
  let!(:offence)        { create(:offence, :miscellaneous) }
  let!(:court)          { create(:court) }
  let(:valid_params) do
    {
      api_key: provider.api_key,
      creator_email: vendor.user.email,
      user_email: litigator.user.email,
      london_rates_apply: true,
      supplier_number: provider.lgfs_supplier_numbers.first,
      case_type_id: create(:case_type, :trial).id,
      case_number: 'A20161234',
      offence_id: offence.id,
      court_id: court.id,
      case_concluded_at: 1.month.ago.as_json,
      actual_trial_length: 10,
      main_hearing_date: Time.zone.today.as_json
    }
  end

  after(:all) { clean_database }

  include_examples 'litigator claim test setup'
  include_examples 'malformed or not iso8601 compliant dates', action: :validate,
                                                               attributes: %i[case_concluded_at main_hearing_date],
                                                               relative_endpoint: LITIGATOR_FINAL_VALIDATE_ENDPOINT
  include_examples 'optional parameter validation', optional_parameters: %i[main_hearing_date],
                                                    relative_endpoint: LITIGATOR_FINAL_VALIDATE_ENDPOINT
  it_behaves_like 'a claim endpoint', relative_endpoint: :final
  it_behaves_like 'a claim validate endpoint', relative_endpoint: :final
  it_behaves_like 'a claim create endpoint', relative_endpoint: :final
end
