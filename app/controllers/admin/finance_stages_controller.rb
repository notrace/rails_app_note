class Admin::FinanceStagesController < Admin::ApplicationController
  before_action :set_finance_stage, only: [:show, :edit, :update, :destroy]

  # GET /finance_stages
  def index
    @finance_stages = FinanceStage.where(is_delete: false).order(created_at:'DESC')
  end

  # GET /finance_stages/1
  def show
  end

  # GET /finance_stages/new
  def new
    @finance_stage = FinanceStage.new
  end

  # GET /finance_stages/1/edit
  def edit
  end

  # POST /finance_stages
  def create
    @finance_stage = FinanceStage.new(finance_stage_params)

    if @finance_stage.save
      redirect_to admin_finance_stages_url, notice: 'Finance stage was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /finance_stages/1
  def update
    if @finance_stage.update(finance_stage_params)
      redirect_to admin_finance_stages_url, notice: 'Finance stage was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /finance_stages/1
  def destroy
    # @finance_stage.destroy
    @finance_stage.update_attribute(is_delete: true)
    redirect_to admin_finance_stages_url, notice: 'Finance stage was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_finance_stage
      @finance_stage = FinanceStage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def finance_stage_params
      params.require(:finance_stage).permit(:name, :num)
    end
end
