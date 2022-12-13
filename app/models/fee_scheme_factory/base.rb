module FeeSchemeFactory
  class Base
    def self.call(...) = new(...).call

    def initialize(representation_order_date:, main_hearing_date:)
      @representation_order_date = representation_order_date
      @main_hearing_date = main_hearing_date
    end

    def call
      FeeScheme.find_by(name:, version:)
    end

    private

    def clair_contingency
      @main_hearing_date && @main_hearing_date >= Settings.clair_contingency_date
    end
  end
end
