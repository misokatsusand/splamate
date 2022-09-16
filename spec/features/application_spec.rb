require 'rails_helper'

RSpec.describe "Application_view", type: :feature do
  describe 'partialについて' do
    let(:user) { create(:user) }

    it 'headerが表示されること' do
      visit root_path
      expect(page).to have_selector "img[src$='/logo.png']"
    end

    it 'footerが表示されること' do
      visit root_path
      expect(page).to have_content 'Copyright'
    end

    it 'flashが表示されること' do
      visit edit_user_path(user.id)
      expect(page).to have_content '編集権限がありません'
    end
  end

  describe 'headerのログインボタンについて' do
    before do
      OmniAuth.config.mock_auth[:twitter] = nil
    end

    context 'ログイン済のとき' do
      before do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        visit '/auth/:provider/callback'
      end

      it 'ログインユーザのアイコンが表示されること' do
        expect(page).to have_selector "img[src$='/test_image.jpg']"
      end

      it 'ログインボタンが表示されないこと' do
        expect(page).not_to have_content 'ログイン'
      end
    end

    context '未ログインのとき' do
      before do
        visit root_path
      end

      it 'ログインユーザのアイコンが表示されないこと' do
        expect(page).not_to have_selector "img[src$='/test_image.jpg']"
      end

      it 'ログインボタンが表示されること' do
        expect(page).to have_content 'ログイン'
      end
    end
  end
end
