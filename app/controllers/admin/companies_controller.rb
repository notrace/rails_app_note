class Admin::CompaniesController < Admin::ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # GET /companies
  def index
    @companies = Company.where(is_delete: false).order(created_at:"DESC")
  end

  # GET /companies/1
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to admin_companies_url, notice: 'Company was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      redirect_to admin_companies_url, notice: 'Company was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /companies/1
  def destroy
    # @company.destroy
    @company.update_attribute(is_delete: true)
    redirect_to admin_companies_url, notice: 'Company was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def company_params
     if params[:company][:im_user_id].present?
        params[:company][:im_user_id] = params[:company][:im_user_id].to_i
      end
      params.require(:company).permit(:name, :desc, :logo, :city, :investment_id, :team_scope, :shares_value, :born_date, :bp, :bp_logo, :web_url, :ios_url, :wechat, :recommend_reason, :trade_tag, :finance_stage_id, :region_id, :recommend, :investment_target, :investment_will, :trade_tag, :trade_tag_list, :im_user_id)
    end
end
