# coding: utf-8
module GotoErrorConcern
  extend ActiveSupport::Concern

  included do
    class GotoError < StandardError; end
    rescue_from GotoError, with: :handle_goto_error
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from Exception do |exception|
      if exception.instance_of? GotoError
        handle_goto_error
      elsif exception.instance_of? ActiveRecord::RecordNotFound
        record_not_found
      else
        if Rails.env.development?
          raise exception
        else
          err_detail(exception)
        end
      end
    end
  end

  def err_detail(exception,msg="")
    derr = exception.backtrace.select{|e| !(e =~ /gems|shared/)}.join("\n")
    bug_info = "bug ---#{request.url}--#{request.params}---#{request.host}---#{request.user_agent} #{exception.message} #{msg}:\n\n#{derr}"
    logger.debug bug_info
    Push.report_bug "#{request.host} bug:musicmorefun" , bug_info
  end

  def no_route
    render json: { error: '没有这个路由' }, status: 404
  end

  def error! params, code = 400
    @_goto_error = params
    @_goto_error_code = code
    raise GotoError, ''
  end

  def record_not_found
    render json: { error: '记录没找到' }, status: 404
  end

  def handle_goto_error
    if @_goto_error.is_a?(String)
      r = { error: @_goto_error }
    else
      r = @_goto_error
    end

    render json: r, status: @_goto_error_code
  end
end
