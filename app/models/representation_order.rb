# == Schema Information
#
# Table name: representation_orders
#
#  id                        :integer          not null, primary key
#  defendant_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  granting_body             :string(255)
#  maat_reference            :string(255)
#  representation_order_date :date
#

class RepresentationOrder < ActiveRecord::Base

  before_save :upcase_maat_ref

  validates   :granting_body, presence: true, inclusion: { in: Settings.court_types }, unless: -> {self.claim.nil? || self.claim.draft? }
  validates   :maat_reference, presence: true, unless: -> { self.claim.nil? || self.claim.draft? }
  validates   :maat_reference, uniqueness: { case_sensitive: false }

  belongs_to :defendant

  def claim
    self.defendant.try(:claim)
  end

  def upcase_maat_ref
    self.maat_reference.upcase! unless self.maat_reference.blank?
  end

end
