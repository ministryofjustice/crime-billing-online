# == Schema Information
#
# Table name: schemes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :scheme do
    sequence(:name) { |n| "AGFS Fee Scheme #{n}" }
    start_date do
      from = 2.years.ago.to_f
      to = Time.now.to_f
      Time.at(from + rand * (to - from))
    end
    end_date { nil }
  end
end
