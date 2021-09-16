class SurveyMonkeySender
  def self.send_response(feedback)
    new(feedback).send_response
  end

  def initialize(feedback)
    @monkey = SurveyMonkey::Response.new
    @monkey.add_page(:feedback, **payload(feedback))
  end

  def send_response
    @monkey.submit
  end

  private

  def payload(feedback)
    {
      tasks: feedback.task,
      ratings: feedback.rating,
      comments: feedback.comment,
      # TODO: Fix the Feedback class to strip out the empty first element
      reasons: reasons(feedback.reason[1..], feedback.other_reason)
    }.delete_if { |_, value| value.blank? }
  end

  def reasons(reason, other_reason)
    return if reason.blank?

    reason + [{ other: other_reason }]
  end
end
