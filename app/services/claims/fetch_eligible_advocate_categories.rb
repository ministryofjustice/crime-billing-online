module Claims
  class FetchEligibleAdvocateCategories
    def self.for(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
    end

    def call
      return unless claim&.agfs?
      return agfs_reform_categories if agfs_reform? || Offence.in_scheme_ten.include?(claim.offence)
      default_categories
    end

    private

    attr_reader :claim

    def default_categories
      Settings.advocate_categories
    end

    def agfs_reform_categories
      Settings.agfs_reform_advocate_categories
    end

    # TODO: to be changed to solely use fee_scheme objects once rest of app cleared up
    def agfs_reform?
      case claim.fee_scheme
      when 'default'
        false
      when 'fee_reform'
        true
      else
        claim.fee_scheme&.agfs? && claim.fee_scheme.version >= 10
      end
    end
  end
end
