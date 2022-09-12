FactoryBot.define do
  factory :user do
    uid { Faker::Number.number(digits: 18) }
    name { "name_test_#{ Faker::Name.last_name }" }
    nickname { "nickname_test_#{ Faker::Name.first_name }" }
    image { "/test_image.jpg" }
    power { 2000 }
    profile { "text_test" }
    friend_code { "#{ Faker::Number.number(digits: 4) }-#{ Faker::Number.number(digits: 4) }-#{ Faker::Number.number(digits: 4) }" }
  end
end
