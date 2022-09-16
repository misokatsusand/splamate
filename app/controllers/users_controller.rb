class UsersController < ApplicationController

  def log_in
    if user = User.create_or_update_from_auth(request.env['omniauth.auth'])
      session[:uid] = user.uid
      if user.friend_code.present?
        flash[:success] = 'ログインしました'
        redirect_to root_path
      else
        flash[:success] = 'ようこそ！プレイヤー情報を入力してください'
        redirect_to "/users/#{user.id}/edit"
      end
    else
      flash[:danger] = '予期せぬエラーが発生しました'
      redirect_to root_path
    end
  end

  def failure
    flash[:danger] = '認証に失敗しました'
    redirect_to root_path
  end

  def show
    @user = User.find(params[:id])
  end
end
