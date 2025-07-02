class Api::UsersController < ApplicationController
    before_action :authorize_request

    def current
        render json: {
            id: @current_user.id,
            username: @current_user.username,
            admin: @current_user.admin,
        }
    end
end