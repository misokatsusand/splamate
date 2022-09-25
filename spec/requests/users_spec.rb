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

  describe '#edit' do
    let(:user) { create(:user) }

    context '編集対象のユーザでログインしているとき' do
      before do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        get '/auth/:provider/callback'
        get edit_user_path(User.find_by(uid: twitter_mock.uid).id)
      end

      it 'リクエストが成功すること' do
        expect(response.status).to eq 200
      end

      it 'パラメータ通りのユーザを取得すること' do
        expect(controller.instance_variable_get('@user')).to eq User.find_by(uid: twitter_mock.uid)
      end
    end

    context '編集対象のユーザ以外でログインしているとき' do
      before do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        get '/auth/:provider/callback'
        get edit_user_path(User.find(user.id))
      end

      it 'トップページへリダイレクトすること' do
        expect(response).to redirect_to root_path
      end
    end

    context 'ログインしていないとき' do
      before do
        get edit_user_path(User.find(user.id))
      end

      it 'トップページへリダイレクトすること' do
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#update' do
    context '正規アクセス' do
      let(:user) { User.find_by(uid: twitter_mock.uid) }

      before do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        get '/auth/:provider/callback'
      end

      context '正常なパラメータを受け取る時' do
        before do
          patch "/users/#{User.find_by(uid: twitter_mock.uid).id}", params: {
            user: { friend_code: '4321-4321-4321', power: 3000, profile: 'test-text2' }
          }
        end

        it 'ログイン中のユーザが取得されること' do
          expect(controller.instance_variable_get('@user')).to eq user
        end

        it 'パラメータ通りにデータが変更されること' do
          expect(user.friend_code).to eq '4321-4321-4321'
          expect(user.power).to eq 3000
          expect(user.profile).to eq 'test-text2'
        end

        it 'ユーザ詳細ページへリダイレクトすること' do
          expect(response).to redirect_to user_path(user.id)
        end
      end

      context '入力フォームにないパラメータを受け取る時' do
        before do
          patch "/users/#{User.find_by(uid: twitter_mock.uid).id}", params: {
            user: { id: 1234, friend_code: '4321-4321-4321', power: 3000, profile: 'test-text2' }
          }
        end

        it '入力フォームにないデータが変更から保護されること' do
          expect(user.id).not_to eq 1234
        end

        it '入力フォームにあるデータはパラメータ通りにデータが変更されること' do
          expect(user.friend_code).to eq '4321-4321-4321'
          expect(user.power).to eq 3000
          expect(user.profile).to eq 'test-text2'
        end
      end

      context '異常なパラメータを受け取る時' do
        before do
          patch "/users/#{User.find_by(uid: twitter_mock.uid).id}", params: {
            user: { friend_code: '1234-1234-1234-1234', power: 9999, profile: 'test-text' }
          }
        end

        it 'データが変更されないこと' do
          expect(user.friend_code).to be_nil
          expect(user.power).to be_nil
          expect(user.profile).to be_nil
        end
      end
    end

    context '不正アクセス' do
      let(:user) { create(:user, friend_code: '1234-1234-1234', power: 2000, profile: 'test-text') }

      context 'ログイン中のユーザ以外からpostされたとき' do
        let(:hacker) { User.find_by(uid: twitter_mock.uid) }

        before do
          Rails.application.env_config['omniauth.auth'] = twitter_mock
          get '/auth/:provider/callback'
          patch "/users/#{user.id}", params: { user: { friend_code: '9999-9999-9999', power: 1000, profile: '不正アクセス' } }
        end

        it '不正アクセスしたユーザ自身のデータに変更が適用されること' do
          expect(hacker.friend_code).to eq '9999-9999-9999'
          expect(hacker.power).to eq 1000
          expect(hacker.profile).to eq '不正アクセス'
        end

        it '被害ユーザのデータが変更されないこと' do
          expect(user.friend_code).to eq '1234-1234-1234'
          expect(user.power).to eq 2000
          expect(user.profile).to eq 'test-text'
        end
      end

      context 'ログインしていない状態でpostされたとき' do
        before do
          patch "/users/#{user.id}", params: { user: { friend_code: '9999-9999-9999', power: 1000, profile: '不正アクセス' } }
        end

        it 'トップページへリダイレクトすること' do
          expect(response).to redirect_to root_path
        end

        it '被害ユーザのデータが変更されないこと' do
          expect(user.friend_code).to eq '1234-1234-1234'
          expect(user.power).to eq 2000
          expect(user.profile).to eq 'test-text'
        end
      end
    end
  end
end
