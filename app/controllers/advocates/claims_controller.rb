class Advocates::ClaimsController < Advocates::ApplicationController
  respond_to :html
  before_action :set_claim, only: [:show, :edit, :update, :destroy]
  before_action :set_context, only: [:index, :outstanding, :authorised ]
  before_action :set_financial_summary, only: [:index, :outstanding, :authorised]
  before_action :set_search_options, only: [:index]

  def landing; end

  def index
    claims = @context.claims.order(created_at: :desc)

    params[:search_field] ||= 'Defendant'

    if params[:search].present?
      claims = case params[:search_field]
        when 'All'
          claims.search(:advocate_name, :defendant_name, params[:search])
        when 'Advocate'
          claims.search(:advocate_name, params[:search])
        when 'Defendant'
          claims.search(:defendant_name, params[:search])
      end
    end

    @claims = claims

    @draft_claims     = claims.advocate_dashboard_draft
    @rejected_claims  = claims.advocate_dashboard_rejected
    @submitted_claims = claims.advocate_dashboard_submitted
    @part_paid_claims = claims.advocate_dashboard_part_paid
    @completed_claims = claims.advocate_dashboard_completed
  end

  def outstanding
    @claims = @financial_summary.outstanding_claims
    @total_value = @financial_summary.total_outstanding_claim_value
  end

  def authorised
    @claims = @financial_summary.authorised_claims
    @total_value = @financial_summary.total_authorised_claim_value
  end

  def show
    @doc_types = DocumentType.all
    @messages = @claim.messages.most_recent_first
    @message = @claim.messages.build
  end

  def new
    @claim = Claim.new
    @claim.instantiate_basic_fees
    load_advocates_in_chamber
    @advocates_in_chamber = current_user.persona.advocates_in_chamber if current_user.persona.admin?
    build_nested_resources
  end

  def edit
    load_advocates_in_chamber
    redirect_to advocates_claims_url, notice: 'Can only edit "draft" or "submitted" claims' unless @claim.editable?
  end

  def confirmation; end

  def create
    form_params = claim_params
    form_params[:advocate_id] = current_user.persona.id unless current_user.persona.admin?
    form_params[:creator_id] = current_user.persona.id
    @claim = Claim.new(form_params)
    @claim.documents.each { |d| d.advocate_id = @claim.advocate_id }
    load_advocates_in_chamber

    case params[:commit]
      when 'Submit to LAA'
        begin
          @claim.submit!
          @claim.save
          redirect_to confirmation_advocates_claim_path(@claim)
        rescue
          @claim.fees = @claim.instantiate_basic_fees(claim_params['basic_fees_attributes'])
          build_nested_resources
          render action: :new
        end
      else
        if @claim.save
          redirect_to advocates_claims_path, notice: 'Draft claim saved'
        else
          @claim.fees = @claim.instantiate_basic_fees(claim_params['basic_fees_attributes'])
          build_nested_resources
          render action: :new
        end
    end
  end

  def update
    load_advocates_in_chamber

    case params[:commit]
      when 'Submit to LAA'
        @claim.update(claim_params)

        begin
          @claim.submit!
          redirect_to confirmation_advocates_claim_path(@claim), notice: 'Claim submitted to LAA'
        rescue
          build_nested_resources
          render action: :edit
        end
      else
        if @claim.update(claim_params)
          redirect_to advocates_claims_path, notice: 'Draft claim saved'
        else
          build_nested_resources
          render action: :edit
        end
    end
  end

  def destroy
    @claim.archive_pending_delete!
    respond_with @claim, { location: advocates_claims_url, notice: 'Claim deleted' }
  end

  private

  def load_advocates_in_chamber
    @advocates_in_chamber = current_user.persona.advocates_in_chamber if current_user.persona.admin?
  end

  def set_context
    if current_user.persona.admin? && current_user.persona.chamber
      @context = current_user.persona.chamber
    else
      @context = current_user
    end
  end

  def set_claim
    @claim = Claim.find(params[:id])
  end

  def set_financial_summary
    @financial_summary = Claims::FinancialSummary.new(@context)
  end

  def claim_params
    params.require(:claim).permit(
     :advocate_id,
     :court_id,
     :scheme_id,
     :case_number,
     :case_type,
     :offence_id,
     :first_day_of_trial,
     :estimated_trial_length,
     :actual_trial_length,
     :advocate_category,
     :additional_information,
     :prosecuting_authority,
     :indictment_number,
     :apply_vat,
     defendants_attributes: [
       :id,
       :claim_id,
       :first_name,
       :middle_name,
       :last_name,
       :date_of_birth,
       :representation_order_date,
       :order_for_judicial_apportionment,
       :maat_reference,
       :_destroy,
       representation_orders_attributes: [ :document ]
     ],
     basic_fees_attributes: [
       :id,
       :claim_id,
       :fee_type_id,
       :fee_id,
       :quantity,
       :rate,
       :_destroy,
       dates_attended_attributes: [
          :id,
          :fee_id,
          :date,
          :date_to,
          :_destroy
        ]
     ],
     non_basic_fees_attributes: [
       :id,
       :claim_id,
       :fee_type_id,
       :fee_id,
       :quantity,
       :rate,
       :_destroy,
       dates_attended_attributes: [
          :id,
          :fee_id,
          :date,
          :date_to,
          :_destroy
        ]
      ],
     expenses_attributes: [
       :id,
       :claim_id,
       :expense_type_id,
       :location,
       :quantity,
       :rate,
       :_destroy
     ],
     documents_attributes: [
       :id,
       :notes,
       :advocate_id,
       :claim_id,
       :document_type_id,
       :document,
       :description,
       :_destroy
     ]
    )
  end

  def build_nested_resources
    @claim.defendants.build if @claim.defendants.none?
    @claim.defendants.each { |d| d.representation_orders.build if d.representation_orders.none? }
    @claim.non_basic_fees.build if @claim.non_basic_fees.none?
    @claim.expenses.build if @claim.expenses.none?
    @claim.documents.build if @claim.documents.none?
  end

  def set_search_options
    if current_user.persona.admin?
      @search_options = ['All', 'Advocate', 'Defendant']
    else
      @search_options = ['All', 'Defendant']
    end
  end
end
