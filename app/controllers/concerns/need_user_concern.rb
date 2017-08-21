# coding: utf-8
module NeedUserConcern
  extend ActiveSupport::Concern

  NOT_EXIST = :"not.exist..."

  included do
    helper_method :current_user
  end

  def current_user
    if @current_user == NOT_EXIST
       return nil
    end
  end


  def need_user!
    if current_user.blank?
      error! "请登录", 401
    end
  end

  module ClassMethods
    def need_user! *args,&blk
      before_action :need_user!, *args,&blk
    end
  end
end
