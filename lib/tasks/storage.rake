require 'tasks/rake_helpers/storage.rb'

namespace :storage do
  desc 'Migrate assets from Paperclip to Active Storage'
  task :migrate, [:model] => :environment do |_task, args|
    Storage.migrate args[:model]
  end

  desc 'Create dummy assets files'
  task :dummy_files, [:model] => :environment do |_task, args|
    Storage.make_dummy_files_for args[:model]
  end

  desc 'Calculate checksums'
  task :calculate_checksums, [:model] => :environment do |_task, args|
    module TempStats
      class StatsReport < ApplicationRecord
        include S3Headers
        self.table_name = 'stats_reports'
        has_attached_file :document, s3_headers.merge(REPORTS_STORAGE_OPTIONS)
      end
    end

    class TempMessage < ApplicationRecord
      include S3Headers
      self.table_name = 'messages'
      has_attached_file :attachment, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
    end

    class TempDocument < ApplicationRecord
      include S3Headers
      self.table_name = 'documents'
      has_attached_file :converted_preview_document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
      has_attached_file :document, s3_headers.merge(PAPERCLIP_STORAGE_OPTIONS)
    end

    case args[:model]
    when 'stats_reports'
      records = TempStats::StatsReport.where.not(document_file_name: nil).where(as_document_checksum: nil)
    when 'messages'
      records = TempMessage.where.not(attachment_file_name: nil).where(as_attachment_checksum: nil)
    when 'documents'
      records = TempDocument.where(as_document_checksum: nil)
    else
      puts "Cannot calculate checksums for: #{args[:model]}"
      exit
    end

    Storage.set_checksums(records: records, model: args[:model])
  end
end