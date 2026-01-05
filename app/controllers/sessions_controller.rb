
class SessionsController < ApplicationController
  def login
    email = params[:email]
    password = params[:password]

    # Get admin credentials from Rails encrypted credentials
    admin_email = Rails.application.credentials.admin_email
    admin_password = Rails.application.credentials.admin_password

    # Validate email and password
    if email == admin_email && password == admin_password
      # Generate JWT token with user email
      payload = { email: email, exp: 24.hours.from_now.to_i }
      secret_key = Rails.application.credentials.secret_key_base
      token = JWT.encode(payload, secret_key, "HS256")

      render json: { token: token }, status: :ok
    else
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end

  def logout
    cookies.delete(:auth_token, httponly: true)
    render json: { message: "logout successful" }, status: :ok
  end

  def authenticated
    # TODO: return json { authenticated: true/false }
  end
end
