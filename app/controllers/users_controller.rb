class UsersController < ApplicationController
  before_action :authenticate_user,{ only: [:log_out, :update] }

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

  def log_out
    session.delete(:uid)
    @current_user = nil
    flash[:success] = 'ログアウトしました'
    redirect_to root_path
  end

  def failure
    flash[:danger] = '認証に失敗しました'
    redirect_to root_path
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    unless params[:id].to_i == @current_user.id
      flash[:danger] = '編集権限がありません'
      redirect_to root_path
    end
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(@current_user.id)
    if params[:user][:friend_code].blank? or params[:user][:power].blank?
      @error_message = "必須項目を入力してください"
      @user.friend_code = params[:user][:friend_code]
      @user.power = params[:user][:power]
      @user.profile = params[:user][:profile]
      render "users/edit"
    else
      if @user.update(params.require(:user).permit(:friend_code, :power, :profile))
        flash[:success] = "プロフィールを更新しました"
        redirect_to user_path(@current_user.id)
      else
        flash[:danger] = "プロフィールを更新できませんでした"
        render "users/edit"
      end
    end
  end
end
