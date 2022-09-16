require 'rails_helper'

RSpec.describe "Users_view", type: :feature do

  before do
    OmniAuth.config.mock_auth[:twitter] = nil
  end

  describe '#log_in' do
    context 'twitter認証をしたとき' do
      context 'フレンドコードが存在するとき' do
        let!(:user_with_friend_code) { create(:user, uid:"111111111111111111") }

        it '"ログインしました"と表示されること' do
          Rails.application.env_config['omniauth.auth'] = twitter_mock_with_friend_code
          visit root_path
          click_on 'ログイン'
          expect(page).to have_content "ログインしました"
        end
      end

      context 'フレンドコードが存在しないとき' do
        it '"ようこそ！プレイヤー情報を入力してください"と表示されること' do
          Rails.application.env_config['omniauth.auth'] = twitter_mock
          visit root_path
          click_on 'ログイン'
          expect(page).to have_content "ようこそ！プレイヤー情報を入力してください"
        end
      end
    end

    context 'twitter認証をキャンセルしたとき(#failureのtest)' do
      it '"認証に失敗しました"と表示されること' do
        Rails.application.env_config['omniauth.auth'] = twitter_invalid_mock
        visit root_path
        click_on 'ログイン'
        expect(page).to have_content "認証に失敗しました"
      end
    end

    context 'twitter認証に問題があったとき' do
      it '"予期せぬエラーが発生しました"と表示されること' do
        Rails.application.env_config['omniauth.auth'] = nil
        visit root_path
        click_on 'ログイン'
        expect(page).to have_content "予期せぬエラーが発生しました"
      end
    end
  end
end
