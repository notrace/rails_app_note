module Api
  module V1
    class PasswordsController < DeviseTokenAuth::ApplicationController
      include GotoErrorConcern
      before_action :set_user_by_token, :only => [:update]
      skip_after_action :update_auth_header, :only => [:create, :forgot_create]

      # this action is responsible for generating password reset tokens and
      # sending emails
      def create
        unless resource_params[:email]
          return render_create_error_missing_email
        end

        # give redirect value from params priority
        @redirect_url = params[:redirect_url]

        # fall back to default value if provided
        @redirect_url ||= DeviseTokenAuth.default_password_reset_url

        unless @redirect_url
          return render_create_error_missing_redirect_url
        end

        # if whitelist is set, validate redirect_url against whitelist
        if DeviseTokenAuth.redirect_whitelist
          unless DeviseTokenAuth::Url.whitelisted?(@redirect_url)
            return render_create_error_not_allowed_redirect_url
          end
        end

        # honor devise configuration for case_insensitive_keys
        if resource_class.case_insensitive_keys.include?(:email)
          @email = resource_params[:email].downcase
        else
          @email = resource_params[:email]
        end

        q = "uid = ? AND provider='email'"

        # fix for mysql default case insensitivity
        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = "BINARY uid = ? AND provider='email'"
        end

        @resource = resource_class.where(q, @email).first

        @errors = nil
        @error_status = 400

        if @resource
          yield @resource if block_given?
          @resource.send_reset_password_instructions({
            email: @email,
            provider: 'email',
            redirect_url: @redirect_url,
            client_config: params[:config_name]
          })

          if @resource.errors.empty?
            return render_create_success
          else
            @errors = @resource.errors
          end
        else
          @errors = [I18n.t("devise_token_auth.passwords.user_not_found", email: @email)]
          @error_status = 404
        end

        if @errors
          return render_create_error
        end
      end

# reset_password_token
# token = set_reset_password_token
      def forgot_create
        check_security_code

        if resource_class.case_insensitive_keys.include?(:phone)
          @phone = resource_params[:phone].downcase
        else
          @phone = resource_params[:phone]
        end

        q = "uid = ?"

        # fix for mysql default case insensitivity
        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = "BINARY uid = ? AND provider='phone'"
        end

        @resource = resource_class.where(q, @phone).first

        @errors = nil
        @error_status = 400

        if @resource
          @resource.allow_password_change = true;
          @resource.save!
          sign_in(:user, @resource, store: false, bypass: false)
          yield @resource if block_given?

          if @resource.errors.empty?
            return render_create_success
          else
            @errors = @resource.errors
          end
        else
          @errors = [I18n.t("devise_token_auth.passwords.user_not_found", email: @email)]
          @error_status = 404
        end

        if @errors
          return render_create_error
        end
      end

      # this is where users arrive after visiting the password reset confirmation link
      def edit
        if !ShortMessage.auth_security_code(params[:phone], params[:code])
          return render_security_code_error
        end
        if resource_class.case_insensitive_keys.include?(:phone)
          @phone = resource_params[:phone].downcase
        else
          @phone = resource_params[:phone]
        end

        q = "uid = ?"

        # fix for mysql default case insensitivity
        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = "BINARY uid = ? AND provider='phone'"
        end

        @resource = resource_class.where(q, @phone).first

        @errors = nil
        @error_status = 400

        if @resource && @resource.id
          client_id  = SecureRandom.urlsafe_base64(nil, false)
          token      = SecureRandom.urlsafe_base64(nil, false)
          token_hash = BCrypt::Password.create(token)
          expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

          @resource.tokens[client_id] = {
            token:  token_hash,
            expiry: expiry
          }

          # ensure that user is confirmed
          @resource.skip_confirmation! if @resource.devise_modules.include?(:confirmable) && !@resource.confirmed_at

          # allow user to change password once without current_password
          @resource.allow_password_change = true;

          @resource.save!

          update_auth_header
          sign_in(:user, @resource, store: false, bypass: false)
          yield @resource if block_given?
          response.headers.merge!(@resource.create_new_auth_token)
          render_create_success
        else
          @errors = [I18n.t("devise_token_auth.passwords.user_not_found", email: @email)]
          @error_status = 404
        end

        if @errors
          return render_create_error
        end
      end

      def update
        # make sure user is authorized
        unless @resource
          return render_update_error_unauthorized
        end

        # make sure account doesn't use oauth2 provider
        # unless @resource.provider == 'email'
        #   return render_update_error_password_not_required
        # end

        if (password_resource_params[:old_password] && !@resource.valid_password?(params[:old_password]))
          return render_update_error_password
        end
        # ensure that password params were sent
        unless password_resource_params[:password] && password_resource_params[:password_confirmation]
          return render_update_error_missing_password
        end

        if @resource.send(resource_update_method, password_resource_params)
          @resource.allow_password_change = false

          yield @resource if block_given?
          return render_update_success
        else
          return render_update_error
        end
      end

      protected

      def resource_update_method
        if DeviseTokenAuth.check_current_password_before_update == false or @resource.allow_password_change == true
          "update_attributes"
        else
          "update_with_password"
        end
      end

      def render_create_error_missing_email
        render json: {
          success: false,
          errors: [I18n.t("devise_token_auth.passwords.missing_email")]
        }, status: 401
      end

      def render_create_error_missing_redirect_url
        render json: {
          success: false,
          errors: [I18n.t("devise_token_auth.passwords.missing_redirect_url")]
        }, status: 401
      end

      def render_create_error_not_allowed_redirect_url
        render json: {
          status: 'error',
          data:   resource_data,
          errors: [I18n.t("devise_token_auth.passwords.not_allowed_redirect_url", redirect_url: @redirect_url)]
        }, status: 422
      end

      def render_create_success
        render json: {
          data: resource_data(resource_json: @resource.token_validation_response)
        }
      end

      # def render_create_success
      #   render json: {
      #     success: true,
      #     message: I18n.t("devise_token_auth.passwords.sended", email: @email)
      #   }
      # end

      def render_create_error
        render json: {
          success: false,
          errors: @errors,
        }, status: @error_status
      end

      def render_edit_error
        raise ActionController::RoutingError.new('Not Found')
      end

      def render_update_error_password
        render json: {
          success: false,
          errors: ['error_password']
        }, status: 401
      end

      def render_update_error_unauthorized
        render json: {
          success: false,
          errors: ['Unauthorized']
        }, status: 401
      end

      def render_update_error_password_not_required
        render json: {
          success: false,
          errors: [I18n.t("devise_token_auth.passwords.password_not_required", provider: @resource.provider.humanize)]
        }, status: 422
      end

      def render_update_error_missing_password
        render json: {
          success: false,
          errors: [I18n.t("devise_token_auth.passwords.missing_passwords")]
        }, status: 422
      end

      def render_update_success
        render json: {
          success: true,
          data: resource_data,
          message: I18n.t("devise_token_auth.passwords.successfully_updated")
        }
      end

      def render_update_error
        return render json: {
          success: false,
          errors: resource_errors
        }, status: 422
      end

      def render_security_code_error
        render json: {
          success: false,
          errors: [I18n.t("security_code_error")]
        }, status: 422
      end

      private

      def resource_params
        params.permit(:phone,:email, :password, :password_confirmation, :current_password, :reset_password_token, :redirect_url, :config)
      end

      def password_resource_params
        params.permit(*params_for_resource(:account_update))
      end
      
      def check_security_code
        if !ShortMessage.auth_security_code(params[:phone], params[:code])
          error! '验证码有误', 400
        end
      end

      def resource_data(opts={})
        response_data = opts[:resource_json] || @resource.as_json
        response_data['type'] = @resource.class.name.parameterize
        response_data
      end

    end
  end
end