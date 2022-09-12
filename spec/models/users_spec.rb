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
  end
end
