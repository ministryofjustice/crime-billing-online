# == Schema Information
#
# Table name: claims
#
#  id                       :integer          not null, primary key
#  additional_information   :text
#  apply_vat                :boolean
#  state                    :string
#  last_submitted_at        :datetime
#  case_number              :string
#  advocate_category        :string
#  first_day_of_trial       :date
#  estimated_trial_length   :integer          default(0)
#  actual_trial_length      :integer          default(0)
#  fees_total               :decimal(, )      default(0.0)
#  expenses_total           :decimal(, )      default(0.0)
#  total                    :decimal(, )      default(0.0)
#  external_user_id         :integer
#  court_id                 :integer
#  offence_id               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  valid_until              :datetime
#  cms_number               :string
#  authorised_at            :datetime
#  creator_id               :integer
#  evidence_notes           :text
#  evidence_checklist_ids   :string
#  trial_concluded_at       :date
#  trial_fixed_notice_at    :date
#  trial_fixed_at           :date
#  trial_cracked_at         :date
#  trial_cracked_at_third   :string
#  source                   :string
#  vat_amount               :decimal(, )      default(0.0)
#  uuid                     :uuid
#  case_type_id             :integer
#  form_id                  :string
#  original_submission_date :datetime
#  retrial_started_at       :date
#  retrial_estimated_length :integer          default(0)
#  retrial_actual_length    :integer          default(0)
#  retrial_concluded_at     :date
#  type                     :string
#  disbursements_total      :decimal(, )      default(0.0)
#  case_concluded_at        :date
#  transfer_court_id        :integer
#  supplier_number          :string
#  effective_pcmh_date      :date
#  legal_aid_transfer_date  :date
#  allocation_type          :string
#  transfer_case_number     :string
#  clone_source_id          :integer
#  last_edited_at           :datetime
#  deleted_at               :datetime
#  providers_ref            :string
#  disk_evidence            :boolean          default(FALSE)
#  fees_vat                 :decimal(, )      default(0.0)
#  expenses_vat             :decimal(, )      default(0.0)
#  disbursements_vat        :decimal(, )      default(0.0)
#  value_band_id            :integer
#  retrial_reduction        :boolean          default(FALSE)
#

require 'rails_helper'
require_relative 'shared_examples_for_lgfs_claim'

RSpec.describe Claim::LitigatorClaim, type: :model do

  let(:claim)   { build :litigator_claim }

  it { should delegate_method(:requires_trial_dates?).to(:case_type) }
  it { should delegate_method(:requires_retrial_dates?).to(:case_type) }
  it { is_expected.to respond_to :disable_for_state_transition }

  describe '#final?' do
    it 'should return true' do
      expect(claim.final?).to eql true
    end
  end

  describe '#eligible_case_types' do
    it 'should return only LGFS case types' do
      claim = build :litigator_claim
      CaseType.delete_all
      agfs_lgfs_case_type = create :case_type, name: 'AGFS and LGFS case type', roles: ['agfs', 'lgfs']
      agfs_case_type      = create :case_type, name: 'AGFS case type', roles: ['agfs']
      lgfs_case_type      = create :case_type, name: 'LGFS case type', roles: ['lgfs']

      expect(claim.eligible_case_types).to eq([agfs_lgfs_case_type, lgfs_case_type])
    end
  end

  describe 'requires_case_type?' do
    it 'returns true' do
      expect(claim.requires_case_type?).to be true
    end
  end

  describe 'fixed_fees' do
    context 'no fixed fee exists' do
      it 'returns and empty array' do
        claim = build :litigator_claim
        expect(claim.fixed_fees).to eq( [] )
      end
    end

    context 'a fixed fee exists' do
      it 'returns the fixed fee in an array' do
        claim = create :litigator_claim, :fixed_fee
        fee = create :fixed_fee, claim: claim
        expect(claim.fixed_fees).to eq( [ fee ] )
      end
    end
  end

  context 'eligible misc and fixed fee types' do
    before(:all) do
      @bft1 = create :basic_fee_type
      @bft2 = create :basic_fee_type, :lgfs
      @mft1 = create :misc_fee_type
      @mft2 = create :misc_fee_type, :lgfs
      @fft1 = create :fixed_fee_type
      @fft2 = create :fixed_fee_type, :lgfs
      @claim = build :litigator_claim
    end

    after(:all) do
      clean_database
    end

    describe '#eligible_basic_fee_types' do
      it 'returns only basic fee types for LGFS' do
        expect(@claim.eligible_basic_fee_types).to eq([@bft2])
      end
    end

    describe '#eligible_misc_fee_types' do
      it 'returns only misc fee types for LGFS' do
        expect(@claim.eligible_misc_fee_types).to eq([@mft2])
      end
    end

    describe '#eligible_fixed_fee_types' do
      it 'returns only fixed fee types for LGFS' do
        expect(@claim.eligible_fixed_fee_types).to eq([@fft2])
      end
    end
  end

  describe 'when supplier number has been invalidated' do
    subject { claim.valid? }

    before { SupplierNumber.find_by(supplier_number: claim.supplier_number).delete }

    describe 'on create' do
      describe 'the claim is invalid' do
        let(:claim) { build(:litigator_claim, :fixed_fee, :forced_validation, fixed_fee: build(:fixed_fee, :lgfs)) }

        it { is_expected.to be false }
      end
    end

    describe 'on edit' do
      describe 'the claim is valid' do
        let(:claim) { create(:litigator_claim, :fixed_fee, :forced_validation, fixed_fee: build(:fixed_fee, :lgfs)) }

        it { is_expected.to be true }
      end
    end
  end

  include_examples "common litigator claim attributes"

end
