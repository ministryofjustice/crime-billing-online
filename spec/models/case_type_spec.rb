# == Schema Information
#
# Table name: case_types
#
#  id                      :integer          not null, primary key
#  name                    :string
#  is_fixed_fee            :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  requires_cracked_dates  :boolean
#  requires_trial_dates    :boolean
#  allow_pcmh_fee_type     :boolean          default(FALSE)
#  requires_maat_reference :boolean          default(FALSE)
#  requires_retrial_dates  :boolean          default(FALSE)
#  roles                   :string
#  parent_id               :integer
#  fee_type_code           :string
#

require 'rails_helper'

describe CaseType do
  include DatabaseHousekeeping

  it_behaves_like 'roles', CaseType, CaseType::ROLES

  context 'parents and children' do
    before(:all) do
      @parent_1 = create :case_type, :contempt
      @parent_2 = create :case_type, :hsts
      @child_1 = create :child_case_type, :asbo
      @child_2 = create :child_case_type, :s74
    end

    after(:all) do
      clean_database
    end

    describe 'graduated_fee_type' do
      let!(:grad_fee_type)     { create :graduated_fee_type, code: 'GRAD' }
      let(:grad_case_type)    { build :case_type, fee_type_code: 'GRAD' }
      let(:grad_case_type_x)  { build :case_type, fee_type_code: 'XXXX' }
      let(:fixed_case_type)   { build :case_type, fee_type_code: nil }

      it 'returns nil if no fee_type_code' do
        expect(fixed_case_type.graduated_fee_type).to be_nil
      end

      it 'returns the appropriate graduated fee' do
        expect(grad_case_type.graduated_fee_type).to eq grad_fee_type
      end

      it 'returns nil if the code doesnt exist' do
        expect(grad_case_type_x.graduated_fee_type).to be_nil
      end
    end

    describe 'fixed_fee_type' do
      let!(:fixed_fee_type)     { create :fixed_fee_type, code: 'FIXED' }
      let(:fixed_case_type)    { build :case_type, fee_type_code: 'FIXED' }
      let(:fixed_case_type_x)  { build :case_type, fee_type_code: 'XXXX' }
      let(:grad_case_type)   { build :case_type, fee_type_code: nil }

      it 'returns nil if no fee_type_code' do
        expect(grad_case_type.fixed_fee_type).to be_nil
      end

      it 'returns the appropriate fixed fee' do
        expect(fixed_case_type.fixed_fee_type).to eq fixed_fee_type
      end

      it 'returns nil if the code doesnt exist' do
        expect(fixed_case_type_x.fixed_fee_type).to be_nil
      end
    end

    describe '.parents' do
      it 'does not return child records' do
        expect(CaseType.top_levels).to eq([@parent_1, @parent_2])
      end
    end

    describe '#children' do
      it 'returns all the children' do
        expect(@parent_2.children).to eq( [ @child_2, @child_1 ])
      end

      it 'returns an empty array for records that dont have children' do
        expect(@parent_1.children).to eq( [] )
      end
    end

    describe '#parent' do
      it 'returns the parent' do
        expect(@child_1.parent).to eq @parent_2
      end
    end
  end

end
