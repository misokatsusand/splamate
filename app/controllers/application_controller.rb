class ApplicationController < ActionController::Base
  before_action :set_current_user

  def set_current_user
    if session[:uid]
      @current_user ||= User.find_by(uid: session[:uid])
    else
      @current_user = User.new
    end
  end
end
