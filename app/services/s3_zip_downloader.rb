class S3ZipDownloader
  require 'zip'

  def initialize(claim)
    @claim = claim
  end

  def generate!
    "./tmp/#{@claim.case_number}-#{SecureRandom.uuid}-documents.zip".tap do |bundle|
      build_zip_file @claim.documents, bundle
    end
  end

  private

  def build_zip_file(documents, bundle)
    documents.includes(:document_blob, :converted_preview_document_attachment) # Eager load associations
    Dir.mktmpdir("#{@claim.case_number}-") do |tmp_dir|
      Zip::File.open(bundle, Zip::File::CREATE) do |zip_file|
        documents.map(&:document).each_with_index do |document, i|
          zip_file.add("#{i}_#{document.filename}", local_file(document, tmp_dir))
        end
      end
    end
  end

  def local_file(document, folder)
    File.join(folder, document.filename.to_s).tap do |local_path|
      document.open { |tmp_file| FileUtils.copy(tmp_file, local_path) }
    end
  end
end
