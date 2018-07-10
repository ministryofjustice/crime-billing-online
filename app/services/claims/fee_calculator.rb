module Claims
  class FeeCalculator
    delegate :earliest_representation_order_date,
      :agfs?,
      :case_type,
      :advocate_category,
      :offence,
      to: :@claim

    attr_reader :claim, :fee_type, :advocate_category, :quantity

    def initialize(claim)
      @claim = claim
    end

    def call(options)
      set_attributes(options)

      fee_scheme.calculate do |options|
        options[:scenario] = scenario.id
        options[:offence_class] = offence_class
        options[:advocate_type] = advocate_type
        options[:fee_type_code] = fee_type_code_for(fee_type)

        # units
        # TODO: unit needs to be dynamically determined and values determined
        # Current code only works assuming there is only one unit type and the quantity of
        # the fee is for that unit type.
        units = fee_scheme.units(options).map { |u| u.id.downcase }
        units.each do |unit|
          options[unit.to_sym] = quantity.to_f
        end

        # TODO: aberrations
        # elected case not proceeded is an scenario type with ccr fee type code of AGFS_FEE

        # modifiers
        # TODO: modifier needs to be dynamically determined and could be more than one
        # TODO: modifier values should be based on "munging" uplifts and "number of.." fee types
        # rather than actual number of defendants/cases (based on only paying what they ask for logic)
        # options[:number_of_defendants] = 1
        # options[:number_of_cases] = 1
      end
    end

    private

    def set_attributes(options)
      @fee_type = Fee::BaseFeeType.find(options[:fee_type_id])
      @advocate_category = options[:advocate_category] || advocate_category
      @quantity = options[:quantity] || 1
    end

    def scheme_type
      agfs? ? 'AGFS' : 'LGFS'
    end

    def fee_scheme
      return @fee_scheme if @fee_scheme
      @fee_scheme ||= client.fee_schemes(type: scheme_type, case_date: earliest_representation_order_date.to_s(:db))
    end

    def scenario
      # TODO: create select/find_by calls to list endpoints in client gem
      fee_scheme.scenarios.select do |s|
        s.code.eql?(CCR::CaseTypeAdapter::BILL_SCENARIOS[case_type.fee_type_code.to_sym])
      end.first
    end

    def offence_class
      # some/all fixed fees do not require offences and they have no bearing on calculated fee amount
      # TODO: make conditional on fee scheme version
      offence&.offence_class&.class_letter || offence&.offence_band&.description
    end

    def advocate_type
      CCR::AdvocateCategoryAdapter.code_for(advocate_category)
    end

    def fee_type_code_for(fee_type)
      [
        # CCR::Fee::BasicFeeAdapter::BASIC_FEE_BILL_MAPPINGS, # TODO: all are AGFS_FEE
        CCR::Fee::FixedFeeAdapter::FIXED_FEE_BILL_MAPPINGS,
        CCR::Fee::MiscFeeAdapter::MISC_FEE_BILL_MAPPINGS
      ].inject(&:merge)[fee_type.unique_code.to_sym][:bill_subtype]
    end

    def client
      @client ||= LAA::FeeCalculator.client
    end
  end
end
