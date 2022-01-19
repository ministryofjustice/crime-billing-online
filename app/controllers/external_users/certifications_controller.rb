class ExternalUsers::CertificationsController < ExternalUsers::ApplicationController
  # prepend_before_action :validate_and_amend_multi_parameter_dates
  before_action :set_claim, only: %i[new create update]
  before_action :redirect_already_certified, only: %i[new create]
  before_action :redirect_if_not_valid, only: %i[new create]

  def new
    build_certification
    track_visit({
                  url: 'external_user/%{type}/claim/%{action}/certification',
                  title: '%{action_t} %{type} claim certification'
                }, claim_tracking_substitutions)
  end

  def create
    @claim.build_certification(certification_params)
    if @claim.certification.save && claim_updater.submit
      notify_legacy_importers
      redirect_to confirmation_external_users_claim_path(@claim)
    else
      @certification = @claim.certification
      render action: :new
    end
  end

  def update
    redirect_to external_users_claim_path(@claim), alert: t('shared.certification.alert')
  end

  private

  def redirect_already_certified
    redirect_to external_users_claim_path(@claim), alert: t('shared.certification.alert') if @claim.submitted?
  end

  def redirect_if_not_valid
    return if @claim.invalid_steps.empty?
    redirect_to summary_external_users_claim_path(@claim), alert: t('shared.certification.invalid_claim')
  end

  def notify_legacy_importers
    NotificationQueue::AwsClient.new.send!(@claim)
    Rails.logger.info "Successfully sent #{log_suffix}"
  rescue StandardError => e
    Rails.logger.warn "Error: '#{e.message}' while sending #{log_suffix}"
  end

  def log_suffix
    "message about submission of claim##{@claim.id}(#{@claim.uuid})"
  end

  def build_certification
    @certification = Certification.new(claim: @claim)
    @certification.certified_by = current_user.name
    @certification.certification_date = Date.today
  end

  # def validate_and_amend_multi_parameter_dates
  #   return unless params[:certification]

  #   model_params = params[:certification]
  #   model_params['certification_date(3i)'] = '' if model_params['certification_date(3i)'].to_i > 31
  #   model_params['certification_date(2i)'] = '' if model_params['certification_date(2i)'].to_i > 12
  #   model_params['certification_date(1i)'] = '' if model_params['certification_date(1i)'].to_i < 1900
  # end

  def certification_params
    params.require(:certification).permit(
      :certification_type_id,
      :certified_by,
      :certification_date
    )
  end

  def set_claim
    @claim = Claim::BaseClaim.active.find(params[:claim_id])
  end

  def claim_tracking_substitutions
    { type: @claim.pretty_type, action: @claim.edition_state, action_t: @claim.edition_state.titleize }
  end
end
