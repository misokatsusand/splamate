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

  describe '#log_out' do
    context 'ログイン済のとき' do
      before do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        get '/auth/:provider/callback'
        post '/log_out'
      end

      it 'トップページへリダイレクトすること' do
        expect(response).to redirect_to root_path
      end

      it 'ログアウトすること' do
        get root_path
        expect(controller.instance_variable_get('@current_user').id).to be_nil
      end
    end

    context '未ログインのとき' do
      it 'トップページへリダイレクトすること' do
        post '/log_out'
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#show' do
    let(:user) { create(:user) }

    before do
      get user_path(user)
    end

    it 'リクエストが成功すること' do
      expect(response.status).to eq 200
    end

    it 'パラメータ通りのユーザを取得すること' do
      expect(controller.instance_variable_get('@user')).to eq User.find(user.id)
    end
  end
end
