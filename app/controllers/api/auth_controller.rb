class Api::AuthController < ApplicationController
  def signup
    user = User.new(auth_params)

    if User.exists?(username: user.username)
      render json: { error: "このユーザー名は既に使用されています" }, status: :unprocessable_entity
      return
    end

    if user.save
      token = generate_token(user)
      render json: { token: token, username: user.username }, status: :created
    else
      render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      token = encode_token({ user_id: user.id }) # JWT を生成
      render json: { token: token, user: { id: user.id, username: user.username } }, status: :ok
    else
      render json: { error: "無効なユーザー名またはパスワード" }, status: :unauthorized
    end
  end

  private

  def auth_params
    params.require(:auth).permit(:username, :password)
  end

  def generate_token(user)
    secret_key = Rails.application.credentials.secret_key_base
    JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, "HS256")
  end
end
