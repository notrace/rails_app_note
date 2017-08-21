module Api
  module V1
    class FwdController < Api::V1::ApplicationController
      def send_code
        if @user = User.where(phone: params[:login]).last
          if params[:code_type] == 'find_pwd' && !@user.verified?
            error! "该手机号码未注册"
          end

          if params[:code_type] != 'find_pwd' && @user.verified?
            error! "该手机号码已被注册过"
          end
        else
          if params[:code_type] == 'find_pwd'
            error! "该手机号码未注册"
          else
            @user = User.new(phone: params[:login])
            @user.save!
          end
        end

        if Rails.env == 'development'
          res = @user.deliver_fake_sms
        else
          res = @user.deliver
        end

        if res
          render json: {
            code: 1,
            msg: "发送成功"
          }.to_json
        else
          # code=-2的时候，app端不锁定按钮
          error!({code: -2, msg: "未能成功发送验证码，请输入正确的手机号码"}, 200)
        end
      end
    end
  end
end