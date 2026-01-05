class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  def authenticate_user!
    token = cookies[:auth_token]

    unless token
      render json: { error: "Unauthorized" }, status: :forbidden
      return
    end

    begin
      # Decode JWT token using the secret key from master.key
      secret_key = Rails.application.credentials.secret_key_base
      decoded_token = JWT.decode(token, secret_key, true, { algorithm: "HS256" })

      # Extract email from token
      email = decoded_token[0]["email"]

      # Verify email matches admin email
      admin_email = Rails.application.credentials.admin_email

      unless email == admin_email
        render json: { error: "Unauthorized" }, status: :forbidden
      end
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end
end
