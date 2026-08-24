class OrdersController < ApplicationController
  before_action :set_order, only: :show

  def index
    @orders = Order.includes(:branch, :order_items).order(created_at: :desc)
  end

  def show
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
