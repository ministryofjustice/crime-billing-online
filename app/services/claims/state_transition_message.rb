module Claims
  class StateTransitionMessage
    attr_reader :reasons, :reason_text

    def initialize(state, reasons, reason_text)
      @state = state
      @reasons = reasons
      @reason_text = reason_text
    end

    def call
      @reasons_message ||= reasons_message
    end

    private

    def long_reasons
      reasons.each_with_object([]) do |reason, arr|
        details = ClaimStateTransitionReason.get(reason, reason_text)
        arr << "#{details.description}: #{details.long_description}"
      end
    end

    def reasons_message
      <<~MSG
        Your claim has been #{@state}:

        #{long_reasons.join("\n\n")}
      MSG
    end
  end
end
