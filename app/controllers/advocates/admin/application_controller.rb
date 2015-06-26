class Advocates::Admin::ApplicationController < ApplicationController
  layout 'advocate'
  before_action :authenticate_advocate_admin!

  private

  def authenticate_advocate_admin!
    unless user_signed_in? && current_user.persona.is_a?(Advocate) && current_user.persona.admin?
      redirect_to root_path_url_for_user, alert: 'Must be signed in as a chamber/firm admin'
    end
  end
end
