class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?, :recent_backlogs

  def current_user
    @current_user ||= User.find_by id: session[:user_id] if !session[:user_id].nil?
  end

  def logged_in?
    !!current_user
  end

  def require_user
    if !logged_in?
      flash[:error] = 'You are not eligible to do that.'
      redirect_to root_path
    end
  end

  def recent_backlogs
    Backlog.order(:updated_at).limit(3)
  end

end
