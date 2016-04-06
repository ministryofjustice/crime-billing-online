require 'rails_helper'
require_relative '../validation_helpers'

describe Claim::BaseClaimSubModelValidator do

  let(:claim)               { FactoryGirl.create :claim }
  let(:defendant)           { claim.defendants.first }

  before(:each)              { claim.force_validation = true }

  it 'should call the validators on all the defendants' do
    expect(claim.defendants).to have(1).members
    expect_any_instance_of(DefendantValidator).to receive(:validate_date_of_birth).at_least(:once)
    claim.valid?
  end

  it 'should call the validator on all the representation orders' do
    expect(defendant.representation_orders).to have(2).items
    expect_any_instance_of(RepresentationOrderValidator).to receive(:validate_representation_order_date).at_least(:once)
    claim.valid?
  end

  context 'fees' do
    before(:each) do
      @basic_fee = FactoryGirl.create :basic_fee, :with_date_attended, claim: claim
      @misc_fee = FactoryGirl.create :misc_fee,:with_date_attended, claim: claim
      FactoryGirl.create :date_attended, attended_item: @misc_fee
      claim.fees.map(&:dates_attended).flatten      # iterate through the fees and dates attended so that the examples below know they have been created
      claim.form_step = 2
    end

    it 'should call the validator on all the attended dates for all the fees' do
      expect(claim.fees).to have(3).members # because the claim factory includes one fee
      expect_any_instance_of(DateAttendedValidator).to receive(:validate_date).at_least(:once)
      claim.valid?
    end
  end

  context 'expenses' do
    before(:each) do
      @expense = FactoryGirl.create :expense, :with_date_attended, claim: claim
      FactoryGirl.create :date_attended, attended_item: @expense
      claim.expenses.map(&:dates_attended).flatten       # iterate through the expenses and dates attended so that the examples below know they have been created
      claim.force_validation = true
      claim.form_step = 2
    end

    it 'should call the validator on all the attended dates for all the expenses' do
      expect(claim.expenses).to have(1).member
      expect(claim.expenses.first.dates_attended).to have(2).members
      expect_any_instance_of(DateAttendedValidator).to receive(:validate_date).at_least(:once)
      claim.valid?
    end
  end

  context 'bubbling up errors to the claim' do
    before(:each) do
      claim.force_validation = false
    end

    context 'bubbling up errors from defendant to claim' do
      before do
        claim.force_validation = false
      end
      it 'should transfer errors up to claim' do
        claim.defendants.first.update(date_of_birth: nil)
        claim.defendants.first.update(first_name: nil)
        claim.force_validation = true
        claim.reload.valid?

        expect(claim.errors[:defendant_1_date_of_birth]).to eq(['blank'])
        expect(claim.errors[:defendant_1_first_name]).to eq(['blank'])
      end
    end


    context 'bubbling up errors two levels to the claim' do
      let(:expected_results) do
        {
          defendant_1_representation_order_1_representation_order_date: 'invalid',
          defendant_1_date_of_birth:                                    'blank',
        }
      end

      context 'when claim has case type requiring MAAT reference' do
        before do
          expected_results.merge!(defendant_1_representation_order_1_maat_reference: 'invalid')

          claim.case_type.update_column(:requires_maat_reference, true)

          claim.defendants.first.update(date_of_birth: nil)
          claim.defendants.first.representation_orders.first.update(maat_reference: 'XYZ')
          claim.defendants.first.representation_orders.first.update(representation_order_date: 20.years.ago)
          claim.save!
          claim.force_validation = true

          claim.valid?
        end

        it 'should bubble up the error from reporder to defendant and then to the claim' do
          expected_results.each do |key, message|
            expect(claim.errors[key]).to eq( [message] ), "EXPECTED: #{key} to have error [\"#{message}\"] but found #{claim.errors[key]}"
          end
        end
      end

      context 'when claims does not have case type requiring MAAT reference' do
        before do
          claim.case_type.update_column(:requires_maat_reference, false)

          claim.defendants.first.update(date_of_birth: nil)
          claim.defendants.first.representation_orders.first.update(maat_reference: 'XYZ')
          claim.defendants.first.representation_orders.first.update(representation_order_date: 20.years.ago)
          claim.save!
          claim.force_validation = true

          claim.valid?
        end

        before do
          claim.case_type.update_column(:requires_maat_reference, false)
        end

        it 'should bubble up the error from reporder to defendant and then to the claim' do
          expected_results.each do |key, message|
            expect(claim.errors[key]).to eq( [message] ), "EXPECTED: #{key} to have error [\"#{message}\"] but found #{claim.errors[key]}"
          end
        end
      end
    end
  end

  context 'partial validation' do
    let(:assoc_defendant)     { instance_double(Defendant, valid?: true) }
    let(:assoc_expense)       { instance_double(Expense, valid?: true) }
    let(:assoc_basic_fee)     { instance_double(Fee::BasicFee, valid?: true) }
    let(:assoc_graduated_fee) { instance_double(Fee::GraduatedFee, valid?: true) }
    let(:assoc_assessment)    { instance_double(Assessment, valid?: true) }

    before do
      # has_many
      allow(claim).to receive(:defendants).and_return([assoc_defendant])
      allow(claim).to receive(:expenses).and_return([assoc_expense])
      allow(claim).to receive(:basic_fees).and_return([assoc_basic_fee])

      # has_one
      allow(claim).to receive(:graduated_fee).and_return(assoc_graduated_fee)
      allow(claim).to receive(:assessment).and_return(assoc_assessment)
    end

    context 'from web' do
      before do
        claim.source = 'web'
      end

      context 'for advocate claim' do
        it 'should validate only the associations for the current step (1)' do
          claim.form_step = 1
          expect(assoc_defendant).to receive(:valid?).exactly(1).times
          expect(assoc_expense).to receive(:valid?).exactly(0).times
          expect(assoc_basic_fee).to receive(:valid?).exactly(0).times
          expect(assoc_graduated_fee).to receive(:valid?).exactly(0).times
          expect(assoc_assessment).to receive(:valid?).exactly(0).times
          claim.valid?
        end

        it 'should validate only the associations for the current step (2)' do
          claim.form_step = 2
          expect(assoc_defendant).to receive(:valid?).exactly(0).times
          expect(assoc_expense).to receive(:valid?).exactly(1).times
          expect(assoc_basic_fee).to receive(:valid?).exactly(1).times
          expect(assoc_graduated_fee).to receive(:valid?).exactly(0).times
          expect(assoc_assessment).to receive(:valid?).exactly(1).times
          claim.valid?
        end
      end

      context 'for litigator claim' do
        let(:claim) { FactoryGirl.create :litigator_claim }

        it 'should validate only the associations for the current step (1)' do
          claim.form_step = 1
          expect(assoc_defendant).to receive(:valid?).exactly(1).times
          expect(assoc_expense).to receive(:valid?).exactly(0).times
          expect(assoc_basic_fee).to receive(:valid?).exactly(0).times
          expect(assoc_graduated_fee).to receive(:valid?).exactly(0).times
          expect(assoc_assessment).to receive(:valid?).exactly(0).times
          claim.valid?
        end

        it 'should validate only the associations for the current step (2)' do
          claim.form_step = 2
          expect(assoc_defendant).to receive(:valid?).exactly(0).times
          expect(assoc_expense).to receive(:valid?).exactly(1).times
          expect(assoc_basic_fee).to receive(:valid?).exactly(0).times
          expect(assoc_graduated_fee).to receive(:valid?).exactly(1).times
          expect(assoc_assessment).to receive(:valid?).exactly(1).times
          claim.valid?
        end
      end
    end

    context 'from API' do
      before do
        claim.source = 'api'
      end

      context 'for advocate claim' do
        it 'should validate all the associations for all the steps' do
          expect(assoc_defendant).to receive(:valid?).once
          expect(assoc_expense).to receive(:valid?).once
          expect(assoc_basic_fee).to receive(:valid?).once
          expect(assoc_graduated_fee).not_to receive(:valid?)
          expect(assoc_assessment).to receive(:valid?).once
          claim.valid?
        end
      end

      context 'for litigator claim' do
        let(:claim) { FactoryGirl.create :litigator_claim }

        it 'should validate all the associations for all the steps' do
          expect(assoc_defendant).to receive(:valid?).once
          expect(assoc_basic_fee).not_to receive(:valid?)
          expect(assoc_expense).to receive(:valid?).once
          expect(assoc_graduated_fee).to receive(:valid?).once
          expect(assoc_assessment).to receive(:valid?).once
          claim.valid?
        end
      end
    end
  end
end
