class Admin::PeopleController < Admin::ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  # GET /people
  def index
    @company = Company.where(id: params[:company_id], is_delete: false).first if params[:company_id].present?
    @people = Person.where('company_id is not null',is_delete: false).order(created_at:'DESC')
    @people = @company.where(is_delete: false).people if @company.present?
  end

  # GET /people/1
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
    @user = User.find params[:user_id] if params[:user_id]
    @person.company_id = params[:company_id] if params[:company_id].present?
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  def create
    @person = Person.new(person_params)

    if @person.save
      redirect_to admin_people_url, notice: 'Person was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /people/1
  def update
    if @person.update(person_params)
      redirect_to admin_people_url, notice: 'Person was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /people/1
  def destroy
    @person.update_attribute(is_delete: true)
    redirect_to admin_people_url, notice: 'Person was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def person_params
      params.require(:person).permit(:name, :desc, :position, :avatar, :company_id, :company_name, :phone_num, :email, :area, :nickname)
    end
end
