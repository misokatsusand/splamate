class User < ApplicationRecord
  with_options presence: true do
    validates :uid, uniqueness: true
    validates :name
    validates :nickname
    validates :image
  end

  validates :friend_code, length: { maximum: 14 }
  validates :power, numericality: { greater_than_or_equal_to: 1000, less_than_or_equal_to: 4000 }, allow_nil: true

  def self.create_or_update_from_auth(auth)
    find_or_initialize_by(uid: auth[:uid]).tap do |user|
      user.update!(
        nickname: auth[:info][:nickname],
        name: auth[:info][:name],
        image: auth[:info][:image]
      )
    end
  rescue StandardError
    nil
  end
end
