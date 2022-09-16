class ApplicationController < ActionController::Base
  before_action :set_current_user

  def set_current_user
    if session[:uid]
      @current_user ||= User.find_by(uid: session[:uid])
    else
      @current_user = User.new
    end
  end

  def authenticate_user
    if @current_user.id.nil?
      flash[:danger] = "ログインが必要です"
      redirect_to root_path
    end
  end
end
