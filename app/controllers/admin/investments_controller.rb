class Admin::InvestmentsController < Admin::ApplicationController
  before_action :set_investment, only: [:show, :edit, :update, :destroy]

  # GET /investments
  def index
    @company = Company.where(id: params[:company_id], is_delete: false).first if params[:company_id].present?
    @investments = Investment.where(is_delete: false).order(num:"ASC")
    @investments = @company.investments.where(is_delete: false).order(num:"ASC") if @company.present?
  end

  # GET /investments/1
  def show
  end

  # GET /investments/new
  def new
    @investment = Investment.new
  end

  # GET /investments/1/edit
  def edit
  end

  # POST /investments
  def create
    @investment = Investment.new(investment_params)

    if @investment.save
      redirect_to admin_investments_url, notice: 'Investment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /investments/1
  def update
    if @investment.update(investment_params)
      redirect_to admin_investments_url, notice: 'Investment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /investments/1
  def destroy
    # @investment.destroy
    @investment.update_attribute(is_delete: false)
    redirect_to admin_investments_url, notice: 'Investment was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_investment
      @investment = Investment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def investment_params
      params.require(:investment).permit(:name, :investment_date, :money, :currency, :company_id, :finance_stage_id)
    end
end
