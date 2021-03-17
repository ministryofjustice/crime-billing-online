# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  it { is_expected.to belong_to(:claim) }
  it { is_expected.to belong_to(:sender).class_name('User').inverse_of(:messages_sent) }
  it { is_expected.to have_many(:user_message_statuses) }

  it { is_expected.to validate_presence_of(:sender).with_message('Message sender cannot be blank') }
  it { is_expected.to validate_presence_of(:claim_id).with_message('Message claim_id cannot be blank') }
  it { is_expected.to validate_presence_of(:body).with_message('Message body cannot be blank') }

  it { is_expected.to have_attached_file(:attachment) }

  it_behaves_like 'an s3 bucket'

  it do
    is_expected.to validate_attachment_content_type(:attachment)
      .allowing('application/pdf',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/vnd.oasis.opendocument.text',
                'text/rtf',
                'application/rtf',
                'image/jpeg',
                'image/png',
                'image/tiff',
                'image/bmp',
                'image/x-bitmap')
      .rejecting('text/plain',
                 'text/html')
  end

  it { is_expected.to validate_attachment_size(:attachment).in(0.megabytes..20.megabytes) }

  describe '.for' do
    let(:message) { create(:message) }
    let(:claim) { message.claim }
    let(:user) { message.sender }

    it 'returns the messaages for the user' do
      expect(described_class.for(user)).to eq([message])
    end

    it 'returns the messaages for the claim' do
      expect(described_class.for(claim)).to eq([message])
    end
  end

  describe '.most_recent_first' do
    let!(:first_message) { create(:message) }
    let!(:second_message) { create(:message) }
    let!(:third_message) { create(:message) }

    it 'returns the message sorted by most recent first' do
      expect(described_class.most_recent_first).to eq([third_message, second_message, first_message])
    end
  end

  describe 'user status messages' do
    subject { create(:message) }

    before do
      case_worker = create(:case_worker)
      subject.claim.case_workers << case_worker
    end

    it 'creates unread user message status for all relevant users' do
      subject.reload
      expect(UserMessageStatus.where(read: false).count).to eq(2)
    end
  end

  context 'automatic state change of claim on message creation' do
    let(:claim)     { create :part_authorised_claim }
    let(:user)      { create :user }

    it 'changes claim state from allocated to redetermination if claim_action set to apply for redetermination' do
      claim.messages.build(sender: user, body: 'xxxxx', claim_action: 'Apply for redetermination')
      claim.save
      expect(claim.state).to eq 'redetermination'
    end

    it 'changes claim state from allocated to await_written_reasons if claim_action set to request written reasons' do
      claim.messages.build(sender: user, body: 'xxxxx', claim_action: 'Request written reasons')
      claim.save
      expect(claim.state).to eq 'awaiting_written_reasons'
    end

    it 'changes claim state from if claim_action not set' do
      claim.messages.build(sender: user, body: 'xxxxx')
      claim.save
      expect(claim.state).to eq 'part_authorised'
    end
  end

  describe 'process written reasons' do
    let(:claim)     { create :part_authorised_claim }
    let(:user)      { create :user }

    it 'changes claim state back to what it was before, if written reasons submitted' do
      claim.messages.build(sender: user, body: 'xxxxx', claim_action: 'Request written reasons')
      claim.messages.first.written_reasons_submitted = '1'
      claim.save
      claim.reload

      expect(claim.claim_state_transitions.reorder(created_at: :asc).map(&:event)).to eq([nil, 'submit', 'allocate', 'authorise_part', 'await_written_reasons', 'authorise_part'])
      expect(claim.last_state_transition.author_id).to eq(user.id)
      expect(claim.state).to eq 'part_authorised'
    end
  end

  describe 'after_create :send_email_if_required' do
    let(:claim) { create :allocated_claim }
    let(:creator) { claim.creator }
    let(:case_worker) { claim.case_workers.first }

    it { expect(claim.state).to eq 'allocated' }

    let(:message_params) { { claim_id: claim.id, sender_id: sender.user.id, body: 'lorem ipsum' } }

    context 'when message created by external_user' do
      let(:sender) { creator }

      before do
        creator.user.email_notification_of_message = email_notification_of_message
        creator.save
      end

      context 'when set up to receive mails' do
        let(:email_notification_of_message) { 'true' }

        it 'does not attempt to send an email' do
          expect(NotifyMailer).not_to receive(:message_added_email)
          create(:message, message_params)
        end
      end

      context 'when NOT set up to receive mails' do
        let(:email_notification_of_message) { 'false' }

        it 'does not attempt to send an email' do
          expect(NotifyMailer).not_to receive(:message_added_email)
          create(:message, message_params)
        end
      end
    end

    context 'when case_worker sends messages' do
      let(:sender) { case_worker }

      before do
        creator.user.email_notification_of_message = email_notification_of_message
      end

      context 'when claim creator is set up to receive mails' do
        let(:email_notification_of_message) { 'true' }

        it 'sends an email' do
          mock_mail = double 'Mail message'
          expect(NotifyMailer).to receive(:message_added_email).and_return(mock_mail)
          expect(mock_mail).to receive(:deliver_later)
          create(:message, message_params)
        end

        context 'when has been deleted' do
          before do
            claim.creator.soft_delete
          end

          it 'does not send an email' do
            expect(NotifyMailer).not_to receive(:message_added_email)
            create(:message, message_params)
          end
        end
      end

      context 'when claim creator is not set up to receive mails' do
        let(:email_notification_of_message) { 'false' }

        it 'does not attempt to send an email' do
          expect(NotifyMailer).not_to receive(:message_added_email)
          create(:message, message_params)
        end
      end
    end
  end

  describe '#as_attachment_checksum' do
    context 'with no attachment' do
      let(:message) { create(:message) }

      it 'is nil' do
        expect(message.as_attachment_checksum).to be_nil
      end
    end

    context 'with an attachment' do
      let(:message) { create(:message, :with_attachment) }

      it 'is a checksum' do
        expect(message.as_attachment_checksum).to match(/==$/)
      end
    end
  end

  describe '#attachment#path' do
    let(:message) { create :message, :with_attachment }
    let(:id_partition) { format('%09d', message.id).scan(/\d{3}/).join('/') }
    let(:filename) { message.attachment_file_name }

    before do
      stub_const 'PAPERCLIP_STORAGE_PATH', 'public/assets/test/images/:id_partition/:filename'
    end

    context 'without an Active Storage attachment' do
      it 'has a path based on the filename' do
        expect(message.attachment.path).to eq "public/assets/test/images/#{id_partition}/#{filename}"
      end
    end

    context 'with an Active Storage attachment in disk storage' do
      require 'active_storage/service/disk_service'

      before do
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
            VALUES('test_key', 'testfile_csv', 100, '{}', 100, 'abc==', NOW())
        SQL
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
            VALUES('attachment', 'Message', #{message.id}, LASTVAL(), NOW())
        SQL

        service = ActiveStorage::Service::DiskService.new(root: '/root/')
        allow(ActiveStorage::Blob).to receive(:service).and_return(service)
      end

      it 'has the path for disk storage' do
        expect(message.attachment.path).to eq '/root/te/st/test_key'
      end
    end

    context 'with an Active Storage attachment in S3' do
      require 'active_storage/service/s3_service'

      before do
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
            VALUES('test_key', 'testfile_csv', 100, '{}', 100, 'abc==', NOW())
        SQL
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
            VALUES('attachment', 'Message', #{message.id}, LASTVAL(), NOW())
        SQL

        service = ActiveStorage::Service::S3Service.new(bucket: 'bucket')
        allow(ActiveStorage::Blob).to receive(:service).and_return(service)
      end

      it 'has the path for disk storage' do
        expect(message.attachment.path).to eq 'test_key'
      end
    end
  end
end
