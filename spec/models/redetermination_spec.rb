require 'rails_helper'


describe Redetermination do

  let(:claim)         { FactoryGirl.create :claim }

 
  context 'automatic calculation of total' do
    it 'should calculate the total on save' do
      rd = FactoryGirl.create :redetermination
      expect(rd.total).to eq(rd.fees + rd.expenses)
    end
  end

  context 'default scope' do
    it 'should return the redeterminations in order of creation date' do
      date_1 = 2.months.ago
      date_2 = 1.month.ago
      date_3 = 1.week.ago

      # Given a number of redeterminations written at various times
      [date_3, date_1, date_2].each do |date|
        Timecop.freeze(date) do
          FactoryGirl.create :redetermination, claim: claim
        end
      end
      # when I call claim.redeterminations
      rds = claim.redeterminations

      # it should return them in created_at order
      expect(rds.map(&:created_at)).to eq( [ date_1, date_2, date_3 ])
    end
  end

end