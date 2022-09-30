require_relative 'base_claim_test'

class AdvocateHardshipClaimTest < BaseClaimTest
  def initialize(...)
    @claim_create_endpoint = 'claims/advocates/hardship'
    @email = ADVOCATE_TEST_EMAIL
    @role = 'agfs'

    super
  end

  def test_creation!
    super

    # UPDATE basic fee
    @client.post_to_endpoint('fees', basic_fee_data)

    # CREATE miscellaneous fee
    response = @client.post_to_endpoint('fees', misc_fee_data)

    # add date attended to miscellaneous fee
    @attended_item_id = response['id']
    @client.post_to_endpoint('dates_attended', date_attended_data)

    # add expense
    @client.post_to_endpoint('expenses', expense_data)
  ensure
    clean_up
  end

  def claim_data
    case_stage_unique_code = json_value_at_index(@client.get_dropdown_endpoint(CASE_STAGE_ENDPOINT, api_key, role: 'agfs'), 'unique_code')
    advocate_category = json_value_at_index(@client.get_dropdown_endpoint(ADVOCATE_CATEGORY_ENDPOINT, api_key))
    offence_id = json_value_at_index(@client.get_dropdown_endpoint(OFFENCE_ENDPOINT, api_key), 'id')
    court_id = json_value_at_index(@client.get_dropdown_endpoint(COURT_ENDPOINT, api_key), 'id')

    {
      api_key:,
      creator_email: 'advocateadmin@example.com',
      advocate_email: 'advocate@example.com',
      case_number: 'B20161234',
      providers_ref: SecureRandom.uuid[3..15].upcase,
      case_stage_unique_code:,
      first_day_of_trial: '2020-04-01',
      estimated_trial_length: 1,
      actual_trial_length: 1,
      trial_concluded_at: '2020-04-20',
      trial_fixed_notice_at: '2020-04-02',
      trial_fixed_at: '2020-04-04',
      trial_cracked_at: '2020-04-06',
      trial_cracked_at_third: 'first_third',
      advocate_category:,
      offence_id:,
      court_id:,
      cms_number: '12345678',
      additional_information: 'string',
      apply_vat: true
    }
  end

  def basic_fee_data
    fee_type_id = json_value_at_index(@client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'basic', role: 'agfs'), 'id')

    {
      api_key:,
      claim_id: @claim_uuid,
      fee_type_id:,
      quantity: 1,
      rate: 255.50
    }
  end

  def misc_fee_data
    fee_type_id = json_value_at_index(@client.get_dropdown_endpoint(FEE_TYPE_ENDPOINT, api_key, category: 'misc', role: 'agfs'), 'id')

    {
      api_key:,
      claim_id: @claim_uuid,
      fee_type_id:,
      quantity: 2,
      rate: 1.55
    }
  end
end
