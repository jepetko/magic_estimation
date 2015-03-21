class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by name: params[:username]
    if !user.nil? && user.authenticate(params[:password])
      login_user(user)
    else
      flash[:error] = 'Login credentials invalid.'
      render :new
    end
  end

  def destroy
    if logged_in?
      session[:user_id] = nil
      flash[:notice] = 'You have been logged out successfully.'
    end
    redirect_to root_path
  end

  private

  def login_user(user)
    flash[:notice] = 'Your login was successful.'
    session[:user_id] = user.id
    redirect_to root_path
  end

end