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

  describe '#log_out' do
    context 'ログイン済のとき' do
      it '"ログアウトしました"と表示されること' do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        visit root_path
        click_on 'ログイン'
        visit user_path(User.find_by(uid: twitter_mock.uid).id)
        click_on 'ログアウト'
        expect(page).to have_content "ログアウトしました"
      end
    end

    context '未ログインのとき' do
      it '"ログインが必要です"と表示されること' do
        page.driver.post '/log_out'
        visit root_path
        expect(page).to have_content "ログインが必要です"
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

  describe '#edit,update' do
    context '編集対象のユーザでログインしているとき' do
      let(:user) { User.find_by(uid: twitter_mock.uid) }

      before do
        Rails.application.env_config['omniauth.auth'] = twitter_mock
        visit root_path
        click_on 'ログイン'
        visit edit_user_path(user.id)
      end

      it 'パンくずリストのホームへのリンクが機能すること' do
        click_on 'ホーム'
        expect(page).to have_content 'イカタイとは'
      end

      it 'パンくずリストのプロフィールへのリンクが機能すること' do
        click_on 'プロフィール'
        expect(page).to have_content '編集する'
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

      describe '入力フォーム' do
        context '全て入力された時' do
          before do
            fill_in 'user_friend_code', with: '1234-1234-1234'
            fill_in 'user_power', with: '2000'
            fill_in 'user_profile', with: 'test-text'
            click_on '登録'
          end

          it '"プロフィールを更新しました"と表示されること' do
            expect(page).to have_content 'プロフィールを更新しました'
          end

          it 'ユーザ詳細ページに変更が反映されること' do
            expect(find('table')).to have_content '1234-1234-1234'
            expect(find('table')).to have_content '2000'
            expect(find('table')).to have_content 'test-text'
          end
        end

        context 'フレンドコードが入力されない時' do
          before do
            fill_in 'user_friend_code', with: ''
            fill_in 'user_power', with: '2000'
            fill_in 'user_profile', with: 'test-text'
            click_on '登録'
          end

          it '編集ページが再レンダリングされること' do
            expect(page).to have_content 'プロフィール編集'
          end

          it '"必須項目を入力してください"と表示されること' do
            expect(page).to have_content '必須項目を入力してください'
          end

          it '入力中の値が失われないこと' do
            expect(find('form')).to have_field 'user[power]', with: '2000'
            expect(find('form')).to have_content 'test-text'
          end
        end

        context '最高Xパワーが入力されない時' do
          before do
            fill_in 'user_friend_code', with: '1234-1234-1234'
            fill_in 'user_power', with: ''
            fill_in 'user_profile', with: 'test-text'
            click_on '登録'
          end

          it '編集ページが再レンダリングされること' do
            expect(page).to have_content 'プロフィール編集'
          end

          it '"必須項目を入力してください"と表示されること' do
            expect(page).to have_content '必須項目を入力してください'
          end

          it '入力中の値が失われないこと' do
            expect(find('form')).to have_field 'user[friend_code]', with: '1234-1234-1234'
            expect(find('form')).to have_content 'test-text'
          end
        end
      end

      context '異常なパラメータを受け取る時' do
        before do
          fill_in 'user_friend_code', with: '1234-1234-1234-1234'
          fill_in 'user_power', with: '2000'
          fill_in 'user_profile', with: 'test-text'
          click_on '登録'
        end

        it '"プロフィールを更新できませんでした"と表示されること' do
          expect(page).to have_content 'プロフィールを更新できませんでした'
        end

        it '編集ページが再レンダリングされること' do
          expect(page).to have_content 'プロフィール編集'
        end
      end
    end

    context '編集対象のユーザ以外でログインしているとき' do
      let(:user) { create(:user) }

      before do
        Rails.application.env_config['omniauth.auth'] = twitter_master_mock
        visit root_path
        click_on 'ログイン'
        visit edit_user_path(user.id)
      end

      it '"編集権限がありません"と表示されること' do
        expect(page).to have_content '編集権限がありません'
      end
    end

    context 'ログインしていないとき' do
      let(:user) { create(:user) }

      before do
        visit edit_user_path(user.id)
      end

      it '"編集権限がありません"と表示されること' do
        expect(page).to have_content '編集権限がありません'
      end
    end
  end
end
