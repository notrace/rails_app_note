module Api
  module V1
    class HelperController < Api::V1::ApplicationController
      # params_check :get_security_code do
      #   requires :mobile_number
      # end
      def get_security_code
        error = ShortMessage.generate_security_code(params[:phone])
        if error.blank?
          render json: {}
        else
          return render(json: {status: 'error', success: false, errors: [error] }, status: 400)
        end
      end

      # params_check :check_security_code do
      #   requires :mobile_number
      #   requires :code
      # end
      def check_security_code
        if ShortMessage.auth_security_code(params[:mobile_number], params[:code])
          render json: {}
        else
          # error! '验证码错误', 400
          return render(json: {status: 'error', success: false, errors: ['验证码错误'] }, status: 400)
        end
      end
    end
  end
end