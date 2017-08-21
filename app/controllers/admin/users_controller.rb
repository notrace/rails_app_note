class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_admin]

  # GET /users
  def index
    @users = User.order(created_at:'DESC').paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @user.num = User.order(num:"ASC").last.num + 1 if User.first.present?
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save!
      redirect_to admin_users_url, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    # @user.destroy
    redirect_to admin_users_url, notice: 'User was successfully destroyed.'
  end

  def update_admin
    @user.update(admin: !@user.admin)
    redirect_to admin_users_url, notice: 'User was successfully updated.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      # if params[:user][:status].present?
      #   params[:user][:status] = params[:user][:status].to_i
      # end
      params.require(:user).permit(:name, :status, :refund_note, :is_vcmix)
    end
end
