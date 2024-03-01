require 'rails_helper'

describe Claims::CreateClaim do
  subject(:create_claim) { described_class.new(claim) }

  let(:claim) { build(:advocate_claim, uuid: SecureRandom.uuid) }

  after(:all) do
    clean_database
  end

  describe '#action' do
    subject { create_claim.action }

    it { is_expected.to eq(:new) }
  end

  describe '#draft?' do
    subject { create_claim.draft? }

    it { is_expected.to be_falsey }
  end

  describe '#call' do
    before { expect(subject.claim.persisted?).to be_falsey }

    context 'with a valid Claim' do
      before { expect(subject.claim).to receive(:update_claim_document_owners) }

      after { expect(subject.claim.persisted?).to be_truthy }

      it 'forces validation' do
        expect(subject.claim).to receive(:force_validation=).with(true)
        subject.call
      end

      it 'returns success' do
        result = subject.call

        expect(result.success?).to be_truthy
        expect(result.error_code).to be_nil
      end
    end

    context 'with an invalid Claim' do
      before do
        subject.claim.case_number = nil
        expect(subject.claim).not_to receive(:update_claim_document_owners)
      end

      after { expect(subject.claim.persisted?).to be_falsey }

      it 'returns an error' do
        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.error_code).to eq(:rollback)
      end
    end

    context 'with an already submitted Claim' do
      before do
        allow(subject).to receive(:already_submitted?).and_return(true)
        expect(subject.claim).not_to receive(:update_claim_document_owners)
      end

      after { expect(subject.claim.persisted?).to be_falsey }

      it 'returns an error' do
        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.error_code).to eq(:already_submitted)
      end
    end
  end
end
