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

  describe '#show' do
    let(:user) { create(:user) }

    before do
      visit user_path(user)
    end

    it 'パンくずリストのホームへのリンクが機能すること' do
      click_on 'ホーム'
      expect(page).to have_content 'イカタイとは'
    end

    it 'アイコンが表示されること' do
      expect(find('.twitter_info')).to have_selector "img[src$='/test_image.jpg']"
    end

    it '名前が表示されること' do
      expect(find('.twitter_info')).to have_content user.name
    end

    it 'twitterのidが表示されること' do
      expect(find('.twitter_info')).to have_content user.nickname
    end

    it 'フレンドコードが表示されること' do
      expect(page).to have_content user.friend_code
    end

    it '最高Xパワーが表示されること' do
      expect(page).to have_content user.power
    end

    it 'プロフィールが表示されること' do
      expect(page).to have_content user.profile
    end

    context '閲覧中のユーザでログインしているとき' do
      before do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        visit root_path
        click_on 'ログイン'
        visit user_path(User.find_by(uid: twitter_mock.uid).id)
      end

      it '編集ボタンが表示され、機能すること' do
        click_on '編集する'
        expect(page).to have_content 'プロフィール編集'
      end

      it 'ログアウトボタンが表示され、機能すること' do
        click_on 'ログアウト'
        expect(page).to have_content 'ログイン'
      end
    end

    context '閲覧中のユーザでログインしていないとき' do
      it '編集ボタンとログアウトボタンが表示されないこと' do
        expect(page).not_to have_content 'プロフィール編集'
        expect(page).not_to have_content 'ログアウト'
      end
    end
  end
end
