module Admin
  class ApplicationController < ::ApplicationController
    layout 'admin'

    before_action :authenticate_user!, except:[:update_admin]
    before_action :require_admin, except:[:update_admin]
    before_action :set_active_menu

    def require_admin
      render_404 unless current_user.admin
    end

    def set_active_menu
      @current = ['/' + ['admin', controller_name].join('/')]
    end
  end
end
