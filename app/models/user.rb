class User < ApplicationRecord
  with_options presence: true do
    validates :uid, uniqueness: true
    validates :name
    validates :nickname
    validates :image
  end

  def self.create_or_update_from_auth(auth)
    begin
      find_or_initialize_by(uid: auth[:uid]).tap do |user|
        user.update!(
          nickname: auth[:info][:nickname],
          name: auth[:info][:name],
          image: auth[:info][:image]
        )
      end
    rescue
      return nil
    end
  end
end
