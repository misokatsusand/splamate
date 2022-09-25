require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validationについて' do
    it 'uid,name,nickname,imageが存在するとき、有効であること' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'uidが既に存在するとき、無効であること' do
      user1 = create(:user, uid: "123456789012345678")
      user2 = build(:user, uid: "123456789012345678")
      user2.valid?
      expect(user2.errors[:uid]).to include("has already been taken")
    end

    it 'uidがnilのとき、無効であること' do
      user = build(:user, uid: nil)
      user.valid?
      expect(user.errors[:uid]).to include("can't be blank")
    end

    it 'nameがnilのとき、無効であること' do
      user = build(:user, name: nil)
      user.valid?
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'nicknameがnilのとき、無効であること' do
      user = build(:user, nickname: nil)
      user.valid?
      expect(user.errors[:nickname]).to include("can't be blank")
    end

    it 'imageがnilのとき、無効であること' do
      user = build(:user, image: nil)
      user.valid?
      expect(user.errors[:image]).to include("can't be blank")
    end

    it 'imageが""のときも、nilのときと同じ結果であること' do
      user = build(:user, image: "")
      user.valid?
      expect(user.errors[:image]).to include("can't be blank")
    end

    it 'friend_codeが14文字以上の時、無効であること' do
      user = build(:user, friend_code: "1234-1234-1234-")
      user.valid?
      expect(user.errors[:friend_code]).to include("is too long (maximum is 14 characters)")
    end

    it 'powerが999以下の時、無効であること' do
      user = build(:user, power: 999)
      user.valid?
      expect(user.errors[:power]).to include("must be greater than or equal to 1000")
    end

    it 'powerが400以上の時、無効であること' do
      user = build(:user, power: 4001)
      user.valid?
      expect(user.errors[:power]).to include("must be less than or equal to 4000")
    end
  end

  describe 'self.create_or_update_from_auth(auth)について' do
    before do # 既存ユーザの作成
      User.create_or_update_from_auth(twitter_mock)
    end

    context '既存ユーザのtwitter_authを受け取るとき' do
      let!(:user_before_login) { User.find_by(uid: twitter_mock.uid) }
      let(:user_after_login) { User.find_by(uid: twitter_mock.uid) }

      it 'ログイン前に既存ユーザがDBに存在すること' do
        expect(user_before_login).not_to be_nil
      end

      context 'ログイン時にtwitter情報に変更がないとき' do
        it 'ログイン後の既存ユーザの情報がログイン前と変わらないこと' do
          User.create_or_update_from_auth(twitter_mock)
          expect(user_after_login).to eq user_before_login
        end
      end

      context 'ログイン時にtwitter情報に変更があるとき' do
        describe '前提：' do
          it '検証する2つのtwitterモックが同じアカウント扱いであること' do
            expect(twitter_mock.uid).to eq twitter_mock_updated.uid
          end

          it '事前にDBに変更が反映されていないこと' do
            expect(user_before_login.name).not_to eq twitter_mock_updated.info.name
            expect(user_before_login.nickname).not_to eq twitter_mock_updated.info.nickname
            expect(user_before_login.image).not_to eq twitter_mock_updated.info.image
          end
        end

        describe '本題：' do
          it 'ログイン後に既存ユーザの情報に変更が反映されること' do
            User.create_or_update_from_auth(twitter_mock_updated)
            expect(user_after_login.name).to eq twitter_mock_updated.info.name
            expect(user_after_login.nickname).to eq twitter_mock_updated.info.nickname
            expect(user_after_login.image).to eq twitter_mock_updated.info.image
          end
        end
      end
    end

    context '新規ユーザのtwitter_authを受け取るとき' do
      let(:user_new) { User.find_by(uid: twitter_new_mock.uid) }

      it 'ログイン実行前に新規ユーザがDBに存在しないこと' do
        expect(user_new).to be_nil
      end

      it 'ログイン実行後にname,nickname,imageも登録されること' do
        User.create_or_update_from_auth(twitter_new_mock)
        expect(user_new.name).to eq twitter_new_mock.info.name
        expect(user_new.nickname).to eq twitter_new_mock.info.nickname
        expect(user_new.image).to eq twitter_new_mock.info.image
      end
    end

    context 'twitter_authを受け取らなかったとき' do
      it 'nilを返すこと' do
        expect(User.create_or_update_from_auth(twitter_invalid_mock)).to be_nil
      end
    end
  end
end
