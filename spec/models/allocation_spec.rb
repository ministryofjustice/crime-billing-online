require 'rails_helper'

RSpec.describe Allocation, type: :model do
  it { should validate_presence_of(:case_worker_id) }
  it { should validate_presence_of(:claim_ids) }

  describe '#initialize' do
    subject { Allocation.new(case_worker_id: 1, claim_ids: [1, 2, 3]) }

    it 'sets the case worker id' do
      expect(subject.case_worker_id).to eq(1)
    end

    it 'sets the claim ids' do
      expect(subject.claim_ids).to match_array([1, 2, 3])
    end
  end

  describe '#save' do
    let(:claims) { create_list(:submitted_claim, 5) }
    let(:case_worker) { create(:case_worker) }

    context 'when valid' do
      subject { Allocation.new(claim_ids: claims.map(&:id), case_worker_id: case_worker.id) }

      it 'creates case worker claim join records' do
        subject.save
        expect(CaseWorkerClaim.where(case_worker_id: case_worker.id).map(&:claim_id)).to match_array(claims.map(&:id))
      end

      it 'returns true' do
        expect(subject.save).to eq(true)
      end
    end

    context 'when invalid' do
      subject { Allocation.new(claim_ids: claims.map(&:id)) }

      it 'does not create case worker claim join records' do
        subject.save
        expect(CaseWorkerClaim.count).to eq(0)
      end

      it 'returns false' do
        expect(subject.save).to eq(false)
      end

      it 'contains errors' do
        subject.save
        expect(subject.errors).to_not be_empty
      end
    end
  end
end
