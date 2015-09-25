module DemoData

  class DocumentGenerator


    EXAMPLE_DOC_TYPES = {
      'repo_order_1.pdf'                      => 1,
      'repo_order_2.pdf'                      => 1,
      'repo_order_3.pdf'                      => 1,
      'LAC_1.pdf'                             => 2,
      'commital_bundle.pdf'                   => 3,
      'indictment.pdf'                        => 4,
      'judicial_appointment_order.pdf'        => 5,
      'invoices.pdf'                          => 6,
      'hardship.pdf'                          => 7,
      'previous_fee_advancements.pdf'         => 8,
      'other_supporting_evidence.pdf'         => 9,
      'justification_for_late_submission.pdf' => 10
    }

    def initialize(claim)
      @claim         = claim
      @checklist_ids = []
    end

    def generate!
      rand(1..6).times { add_document_to_claim }
      @claim.update_attribute(:evidence_checklist_ids, @checklist_ids)
    end

    private

    def add_document_to_claim
      doc_index = 1
      while @checklist_ids.include?(doc_index) do
        doc_index = rand(EXAMPLE_DOC_TYPES.size)
      end
      pdf_name = EXAMPLE_DOC_TYPES.keys[doc_index]
      @checklist_ids << EXAMPLE_DOC_TYPES[pdf_name]
      filename = "#{Rails.root}/spec/fixtures/files/#{pdf_name}"
      file = File.open(filename)
      Document.create(
        claim: @claim,
        document: file,
        document_content_type: 'application/pdf',
        advocate: @claim.advocate)
    end
  end
end

