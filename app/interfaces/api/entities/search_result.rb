module API
  module Entities
    class SearchResult < BaseEntity
      include SearchResultHelpers
      expose :id
      expose :uuid
      expose :scheme
      expose :scheme_type
      expose :case_number
      expose :state
      expose :state_display
      expose :court_name
      expose :case_type
      expose :total, format_with: :decimal
      expose :total_display
      expose :external_user
      expose :last_submitted_at
      expose :last_submitted_at_display
      expose :defendants
      expose :maat_references
      expose :filters

      private

      def state_display
        object.state.humanize
      end

      def total_display
        ActiveSupport::NumberHelper.number_to_currency(object.total, precision: 2, delimiter: ',')
      end

      def last_submitted_at
        object.last_submitted_at.to_datetime.to_i
      end

      def last_submitted_at_display
        object.last_submitted_at.strftime('%d/%m/%Y')
      end

      def filters
        [
          disk_evidence,
          redetermination,
          fixed_fee,
          awaiting_written_reasons,
          cracked,
          trial,
          guilty_plea,
          graduated_fees,
          interim_fees,
          warrants,
          interim_disbursements,
          risk_based_bills
        ].join
      end

      def disk_evidence
        object.disk_evidence.eql?('t').to_i
      end

      def redetermination
        object.state.eql?('redetermination').to_i
      end

      def fixed_fee
        (object.is_fixed_fee.eql?('t') && is_submitted?).to_i
      end

      def awaiting_written_reasons
        object.state.eql?('awaiting_written_reasons').to_i
      end

      def cracked
        (['Cracked before retrial', 'Cracked Trial'].include?(object.case_type) && is_submitted?).to_i
      end

      def trial
        (%w[Trial Retrial].include?(object.case_type) && is_submitted?).to_i
      end

      def guilty_plea
        (['Discontinuance', 'Guilty plea'].include?(object.case_type) && is_submitted?).to_i
      end

      def graduated_fees
        ((object.fee_type_code&.in?(graduated_fee_codes).eql?(true) || allocation_type_is_grad?) && is_submitted?).to_i
      end

      def interim_fees
        (interim_claim? && fee_is_interim_type && is_submitted?).to_i
      end

      def warrants
        (interim_claim? && contains_fee_of_type('Warrant')).to_i
      end

      def interim_disbursements
        (interim_claim? && contains_fee_of_type('Disbursement only')).to_i
      end

      def risk_based_bills
        ((risk_based_class_letter && contains_risk_based_fee).eql?(true) && is_submitted?).to_i
      end
    end
  end
end
