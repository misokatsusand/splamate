class User < ApplicationRecord
  with_options presence: true do
    validates :uid, uniqueness: true
    validates :name
    validates :nickname
    validates :image
  end
end
