module OmniauthSupport
  def twitter_mock
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      "provider" => "twitter",
      "uid" => "123456789012345678",
      "info" => {
        "name" => "Mock_name",
        "nickname" => "Mock_nickname",
        "image" => "/test_image.jpg"
      }
    })
  end

  def twitter_mock_updated
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      "provider" => "twitter",
      "uid" => "123456789012345678",
      "info" => {
        "name" => "Mock_name_2",
        "nickname" => "Mock_nickname_2",
        "image" => "/test_image_2.jpg"
      }
    })
  end

  def twitter_master_mock
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      "provider" => "twitter",
      "uid" => Rails.application.credentials.dig(:user, :master_uid),
      "info" => {
        "name" => "Mock_master_name",
        "nickname" => "Mock_master_nickname",
        "image" => "/test_image.jpg"
      }
    })
  end

  def twitter_new_mock
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      "provider" => "twitter",
      "uid" => "876543210987654321",
      "info" => {
        "name" => "Mock_new_name",
        "nickname" => "Mock_new_nickname",
        "image" => "/test_image.jpg"
      }
    })
  end

  def twitter_mock_with_friend_code
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      "provider" => "twitter",
      "uid" => "111111111111111111",
      "info" => {
        "name" => "Mock_with_friend_code_name",
        "nickname" => "Mock_with_friend_code_nickname",
        "image" => "/test_image.jpg"
      }
    })
  end

  def twitter_invalid_mock
    OmniAuth.config.mock_auth[:twitter] = :invalid_credentails
  end
end
