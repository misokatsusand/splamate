require 'rails_helper'

RSpec.describe UsersController, type: :request do
  before do
    OmniAuth.config.mock_auth[:twitter] = nil
  end

  describe '#login' do
    context 'twitter認証をしたとき' do
      context 'フレンドコードが存在するとき' do
        let!(:user_with_friend_code) { create(:user, uid:"111111111111111111") }

        before do
          Rails.application.env_config['omniauth.auth'] = twitter_mock_with_friend_code
          get '/auth/:provider/callback'
        end

        it '対象ユーザでログインすること' do
          get root_path
          expect(controller.instance_variable_get('@current_user')).to eq User.find_by(uid: twitter_mock_with_friend_code.uid)
        end

        it 'トップページへリダイレクトすること' do
          expect(response).to redirect_to root_path
        end
      end

      context 'フレンドコードが存在しないとき' do
        before do
          Rails.application.env_config['omniauth.auth'] = twitter_mock
          get '/auth/:provider/callback'
        end

        it '対象ユーザでログインすること' do
          get root_path
          expect(controller.instance_variable_get('@current_user')).to eq User.find_by(uid: twitter_mock.uid)
        end

        it 'ユーザ編集画面へリダイレクトが発生すること' do
          expect(response).to redirect_to "/users/#{User.find_by(uid: twitter_mock.uid).id}/edit"
        end
      end
    end

    context 'twitter認証をキャンセルしたとき(#failureのtest)' do
      it 'トップページへリダイレクトすること' do
        Rails.application.env_config['omniauth.auth'] = twitter_invalid_mock
        get '/auth/:provider/callback'
        expect(response).to redirect_to root_path
      end
    end

    context 'twitter認証に問題があったとき' do
      it 'トップページへリダイレクトすること' do
        Rails.application.env_config['omniauth.auth'] = nil
        get '/auth/:provider/callback'
        expect(response).to redirect_to root_path
      end
    end
  end
end
