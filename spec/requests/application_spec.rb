require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  describe 'ユーザセッションについて' do
    before do
      OmniAuth.config.mock_auth[:twitter] = nil
    end

    context 'ログイン済のとき' do
      it 'ログインユーザがセットされること' do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        get '/auth/:provider/callback'
        expect(controller.instance_variable_get('@current_user').id).to eq twitter_mock.id
      end
    end

    context '未ログインのとき' do
      it '空のユーザがセットされること' do
        get root_path
        expect(controller.instance_variable_get('@current_user').id).to eq User.new.id
      end
    end
  end
end
