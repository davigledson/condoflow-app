# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user!
    redirect_to login_path, alert: "Faça login para continuar." unless logged_in?
  end

  def require_admin!
    redirect_to root_path, alert: "Acesso negado." unless current_user.admin?
  end

  def require_admin_or_collaborator!
    redirect_to root_path, alert: "Acesso negado." unless current_user.admin? || current_user.collaborator?
  end

  def require_resident!
    redirect_to root_path, alert: "Acesso negado." unless current_user.resident?
  end
end