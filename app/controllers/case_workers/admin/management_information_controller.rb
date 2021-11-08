require 'csv'

class CaseWorkers::Admin::ManagementInformationController < CaseWorkers::Admin::ApplicationController
  include ActiveStorage::SetCurrent

  skip_load_and_authorize_resource only: %i[index download generate]
  before_action -> { authorize! :view, :management_information }, only: %i[index download generate]
  before_action :validate_report_type, only: %i[download generate]

  def index
    @available_report_types = Stats::StatsReport::TYPES.index_with do |report_type|
      Stats::StatsReport.most_recent_by_type(report_type)
    end
    @reports_access = Stats::StatsReport.most_recent_by_type('reports_access_details')
  end

  def download
    log_download_start
    record = Stats::StatsReport.most_recent_by_type(params[:report_type])

    if record.document.attached?
      redirect_to record.document.blob.url(disposition: 'attachment')
    else
      redirect_to case_workers_admin_management_information_url, alert: t('.missing_report')
    end
  end

  def generate
    StatsReportGenerationJob.perform_later(params[:report_type])
    message = t('case_workers.admin.management_information.job_scheduled')
    redirect_to case_workers_admin_management_information_url, flash: { notification: message }
  end

  private

  def validate_report_type
    return if Stats::StatsReport::TYPES.include?(params[:report_type])
    return if params[:report_type] == 'reports_access_details'

    redirect_to case_workers_admin_management_information_url, alert: t('.invalid_report_type')
  end

  def log_download_start
    LogStuff.send(:info,
                  class: 'CaseWorkers::Admin::ManagementInformationController',
                  action: 'download',
                  downloading_user_id: @current_user&.id) do
      'MI Report download started'
    end
  end
end
