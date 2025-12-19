require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_email = Rails.application.credentials.admin_email
    @admin_password = Rails.application.credentials.admin_password
  end

  test "should return JWT token with correct credentials" do
    post login_url, params: { email: @admin_email, password: @admin_password }, as: :json
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response["token"].present?, "Token should be present in response"
    
    # Verify the token can be decoded and contains correct email
    token = json_response["token"]
    secret_key = Rails.application.credentials.secret_key_base
    decoded_token = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
    
    assert_equal @admin_email, decoded_token[0]["email"]
  end

  test "should return 403 when email is missing" do
    post login_url, params: { password: @admin_password }, as: :json
    
    assert_response :forbidden
  end

  test "should return 403 when password is missing" do
    post login_url, params: { email: @admin_email }, as: :json
    
    assert_response :forbidden
  end

  test "should return 403 when email is incorrect" do
    post login_url, params: { email: "wrong@example.com", password: @admin_password }, as: :json
    
    assert_response :forbidden
  end

  test "should return 403 when password is incorrect" do
    post login_url, params: { email: @admin_email, password: "wrongpassword" }, as: :json
    
    assert_response :forbidden
  end

  test "should return 403 when both email and password are missing" do
    post login_url, params: {}, as: :json
    
    assert_response :forbidden
  end

  test "should return 403 when both email and password are incorrect" do
    post login_url, params: { email: "wrong@example.com", password: "wrongpassword" }, as: :json
    
    assert_response :forbidden
  end
end
