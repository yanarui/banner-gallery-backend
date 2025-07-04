class ApplicationController < ActionController::API
  include ActionController::Cookies
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV["SECRET_KEY_BASE"]

  
  def encode_token(payload)
    JWT.encode(payload, SECRET_KEY)
  end

  def decode_token(token)
    begin
      JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")
    rescue JWT::DecodeError
      nil
    end
  end

  private

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(' ').last if header.present?
    secret_key = Rails.application.credentials.secret_key_base

    begin
      decoded = JWT.decode(token, secret_key, true, algorithm: "HS256")
      @current_user = User.find(decoded[0]["user_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
      render json: { error: "認証エラー: #{e.message}" }, status: :unauthorized
    end
  end
end
