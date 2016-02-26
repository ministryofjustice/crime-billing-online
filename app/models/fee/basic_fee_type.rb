# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string
#  code            :string
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  max_amount      :decimal(, )
#  calculated      :boolean          default(TRUE)
#  type            :string
#

class Fee::BasicFeeType < Fee::BaseFeeType

  DATES_ATTENDED_APPLICABLE_FEES = %w( BAF DAF DAH DAJ PCM SAF )

  default_scope { order(id: :asc) }

  def has_dates_attended?
    DATES_ATTENDED_APPLICABLE_FEES.include?(self.code)
  end

   def fee_category_name
    'Basic Fees'
  end

end
