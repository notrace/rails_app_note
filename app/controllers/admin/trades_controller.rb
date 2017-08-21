class Admin::TradesController < Admin::ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :destroy]

  # GET /trades
  def index
    @trades = Trade.where(is_delete: false).order(created_at:'DESC')
  end

  # GET /trades/1
  def show
  end

  # GET /trades/new
  def new
    @trade = Trade.new
    @trade.num = Trade.order(num:"ASC").last.num + 1 if Trade.first.present?
  end

  # GET /trades/1/edit
  def edit
  end

  # POST /trades
  def create
    @trade = Trade.new(trade_params)

    if @trade.save
      redirect_to admin_trades_url, notice: 'Trade was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /trades/1
  def update
    if @trade.update(trade_params)
      redirect_to admin_trades_url, notice: 'Trade was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /trades/1
  def destroy
    # @trade.destroy
    redirect_to admin_trades_url, notice: 'Trade was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trade
      @trade = Trade.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def trade_params
      params.require(:trade).permit(:name, :num)
    end
end
