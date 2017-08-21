module Api
  module V1
    class ApplicationController < ActionController::API
      include DeviseTokenAuth::Concerns::SetUserByToken, GotoErrorConcern
       before_action :authenticate_user!, except: [:get_security_code, :check_security_code]
    end
  end
end