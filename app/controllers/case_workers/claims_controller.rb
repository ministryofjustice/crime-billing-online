class CaseWorkers::ClaimsController < CaseWorkers::ApplicationController
  include PaginationHelpers
  include DocTypes

  skip_load_and_authorize_resource
  authorize_resource class: Claim::BaseClaim

  helper_method :sort_column, :sort_direction, :search_terms

  respond_to :html

  # callback order is important (must set claims before filtering and sorting)
  before_action :set_claims,              only: %i[index archived]
  before_action :filter_current_claims,   only: [:index]
  before_action :filter_archived_claims,  only: [:archived]
  before_action :sort_claims,             only: %i[index archived]

  before_action :set_claim, only: %i[show messages publish enquire download_zip]
  before_action :set_doctypes, only: %i[show update]

  include ReadMessages
  include MessageControlsDisplay

  def index; end

  def archived; end

  def show
    prepare_show_action
  end

  def download_zip
    zipper = S3ZipDownloader.new(@claim)
    zip_file = zipper.generate!

    send_file zip_file,
              filename: "#{@claim.case_number}-documents.zip",
              type: 'application/zip',
              disposition: 'attachment'
  end

  def messages
    render template: 'messages/claim_messages'
  end

  def update
    updater = Claims::CaseWorkerClaimUpdater.new(params[:id], claim_params.merge(current_user: current_user)).update!
    @claim = updater.claim
    @doc_types = DocType.all
    if updater.result == :ok
      redirect_to case_workers_claim_path(params.slice(:messages))
    else
      @claim.errors
      prepare_show_action
      render :show
    end
  end

  private

  def prepare_show_action
    @claim.assessment = Assessment.new if @claim.assessment.nil?
    @doc_types = DocType.all
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build
  end

  def search(states = nil)
    @claims = @claims.search(search_terms, states, *search_options) unless @claims.remote?
  end

  # no longer used because all claims are remote
  # def search_options
  #   options = [:case_number, :maat_reference, :defendant_name]
  #   options << :case_worker_name_or_email if current_user.persona.admin?
  #   options
  # end

  def claim_params
    params.require(:claim).permit(
      :state,
      :reason_text,
      :additional_information,
      assessment_attributes: %i[
        id
        fees
        expenses
        disbursements
        vat_amount
      ],
      redeterminations_attributes: %i[
        id
        fees
        expenses
        disbursements
        vat_amount
      ]
    ).merge(params.permit(state_reason: []))
  end

  def set_claims
    @claims = Claims::CaseWorkerClaims.new(current_user: current_user, action: tab, criteria: criteria_params).claims
  end

  # Only these 2 actions are handle in this controller. Rest of actions in the admin-namespaced controller.
  def tab
    %w[current archived].include?(params[:tab]) ? params[:tab] : 'current'
  end

  def set_claim
    @claim = Claim::BaseClaim.active.find(params[:id])
  end

  def filter_current_claims
    search(Claims::StateMachine::CASEWORKER_DASHBOARD_UNDER_ASSESSMENT_STATES) if search_terms.present?
  end

  def filter_archived_claims
    search(Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES) if search_terms.present?
  end

  def sort_column
    params[:sort].blank? ? 'last_submitted_at' : params[:sort]
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def search_terms
    params[:search]
  end

  def sort_and_paginate
    # GOTCHA: must paginate in same call that sorts/orders
    @claims = @claims.sort(sort_column, sort_direction).page(current_page).per(page_size) unless @claims.remote?
  end

  def sort_claims
    sort_and_paginate
    add_claim_carousel_info
  end

  def criteria_params
    { sorting: sort_column, direction: sort_direction, page: current_page, limit: page_size, search: search_terms }
  end
end
