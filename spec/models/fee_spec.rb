# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  claim_id    :integer
#  fee_type_id :integer
#  quantity    :integer
#  amount      :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#  uuid        :uuid
#  rate        :decimal(, )
#

require 'rails_helper'

RSpec.describe Fee, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:fee_type) }
  it { should have_many(:dates_attended) }

  it { should validate_presence_of(:claim).with_message('blank')}

  describe 'blank quantity should be set to zero before validation' do
    it 'should replace blank quantities with zero before save' do
      fee = FactoryGirl.build :fee, quantity: nil
      expect(fee).to be_valid
      expect(fee.quantity).to eq 0
    end
  end

  describe 'blank rate should be set to zero before validation' do
    it 'should replace blank rate with zero before save' do
      fee = FactoryGirl.build :fee, rate: nil
      expect(fee).to be_valid
      expect(fee.rate).to eq 0
    end
  end

  describe 'blank amount with blank quantity and rate should be set to zero before validation' do
    it 'should replace blank amount with zero before save' do
      fee = FactoryGirl.build :fee, quantity: nil, rate: nil, amount: nil
      expect(fee).to be_valid
      expect(fee.amount).to eq 0
    end
  end

  describe '#calculate_amount' do

    # this should be removed after gamma/private beta claims archived/deleted
    context 'for fees entered before rate was reintroduced' do
      it 'amount is NOT recalculated and rate presence is NOT validated' do
        fee = FactoryGirl.build :fee, quantity: 10, rate: nil, amount: 255
        fee.claim.force_validation = true
        expect(fee).to be_valid
        expect(fee.amount).to eq 255.00
      end
    end

    # this will become default after gamma/private beta claims archived/deleted
    context 'for fees entered after rate was reintroduced' do
      it 'amount is calculated as quantity * rate before validation' do
        fee = FactoryGirl.build :fee, quantity: 12, rate: 3.01
        fee.claim.force_validation = true
        expect(fee).to be_valid
        expect(fee.amount).to eq 36.12
      end
    end

    context 'for fees not requiring calculation' do
      it 'should not calculate the amount' do
        fee = FactoryGirl.build :fee, :ppe_fee, quantity: 999, rate: 2.0, amount: 999
        fee.claim.force_validation = true
        expect(fee).to be_valid
        expect(fee.amount).to eq 999
      end
    end

  end

  describe '.new_blank' do
    it 'should instantiate but not save a fee with all zero values belonging to the claim and fee type' do
      fee_type = FactoryGirl.build :fee_type
      claim = FactoryGirl.build :claim

      fee = Fee.new_blank(claim, fee_type)
      expect(fee.fee_type).to eq fee_type
      expect(fee.claim).to eq claim
      expect(fee.quantity).to eq 0
      expect(fee.amount).to eq 0
      expect(fee).to be_new_record
    end

    # TODO: BAF fee type used to be instatiated to 1 but has been removed - POCA ticket - can remove eventually
    context 'for the BAF basic fee' do
      it 'should be called as part of claim instatiation and assign 0 as quantity for BAF fee types' do
        baf_fee_type = FactoryGirl.create :fee_type, :basic, code: 'BAF'
        claim = FactoryGirl.build :claim
        fee = claim.basic_fees.first
        expect(fee.fee_type.code).to eql 'BAF'
        expect(fee.amount).to eq 0.00
        expect(fee.quantity).to eq 0
        expect(fee).to be_new_record
      end
    end
  end

  describe '#calculated?' do
    it 'should return false for fees flagged as uncalculated' do
      ppe = FactoryGirl.create(:fee_type, :basic, code: 'PPE', calculated: false)
      fee = FactoryGirl.create(:fee, fee_type: ppe)
      expect(fee.calculated?).to be false
    end
    it 'should return true for any other fees' do
      saf = FactoryGirl.create(:fee_type, :basic, code: 'SAF')
      fee = FactoryGirl.create(:fee, fee_type: saf)
      expect(fee.calculated?).to be true
    end
  end

  describe '#blank?' do
    it 'should return true if all value fields are zero' do
      fee = FactoryGirl.create :fee, :all_zero
      expect(fee.blank?).to be true
    end
    it 'should return false if any value fields are non zero' do
      fee = FactoryGirl.create :fee
      expect(fee.blank?).to be false
    end
  end

  describe '#present?' do
    it 'should return false if all value fields are zero' do
      fee = FactoryGirl.create :fee, :all_zero
      expect(fee.present?).to be false
    end
    it 'should return true if any value fields are non zero' do
      fee = FactoryGirl.create :fee
      expect(fee.present?).to be true
    end
  end

  describe '#category' do
    it 'should return the abbreviation of the fee type category' do
      cat = FactoryGirl.create :fee_category
      ft  = FactoryGirl.create :fee_type, fee_category: cat
      fee = FactoryGirl.create :fee, fee_type: ft
      expect(fee.category).to eq cat.abbreviation
    end
  end

  describe '#clear' do
    let(:fee) {FactoryGirl.build :fee, :with_date_attended, quantity: 1, amount: 9.99}

    it 'should set fee amount and quantity to nil' do
      fee.clear
      expect(fee.quantity).to eql nil
      expect(fee.amount).to eql nil
    end

    it 'should destroy any child relations (dates attended)' do
      expect(fee.dates_attended.size).to eql 1
      fee.clear
      expect(fee.dates_attended.size).to eql 0
    end
  end

  describe 'comma formatted inputs' do
    [:quantity, :amount].each do |attribute|
      it "converts input for #{attribute} by stripping commas out" do
        fee = build(:fee)
        fee.send("#{attribute}=", '12,321,111')
        expect(fee.send(attribute)).to eq(12321111)
      end
    end
  end
end
