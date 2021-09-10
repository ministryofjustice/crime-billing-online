class ClaimCleanerService
  class AdvocateSupplementary < ClaimCleanerService
    private

    def destroy_invalid_fees
      misc_fees.delete(ineligible_misc_fees)
    end

    def ineligible_misc_fees
      eligbile_fee_types = Claims::FetchEligibleMiscFeeTypes.new(self).call
      misc_fees.reject do |fee|
        eligbile_fee_types.map(&:unique_code).include?(fee.fee_type.unique_code)
      end
    end
  end
end
