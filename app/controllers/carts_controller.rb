class CartsController < ApplicationController
  before_action :set_cart, only: %i[show edit update destroy]

  # def index
  #   @carts = Cart.includes(:branch).order(created_at: :desc)
  # end

  # def show
  #   @cart_items = @cart.cart_items.includes(branch_menu_item: :menu_item)
  # end

  # Show the current active cart from session
  def current
    @cart = Cart.find_by(id: session[:cart_id])

    if @cart.nil?
      redirect_to order_start_path, alert: "No active cart. Start an order to begin."
      return
    end

    @cart_items = @cart.cart_items.includes(branch_menu_item: :menu_item)
    # @cart_items = @cart.cart_items.includes(branch_menu_item: :menu_item).where(branch_menu_item: { menu_item_availability: true })
    render :show
  end

  def new
    @cart = Cart.new
  end

  def create
    @cart = Cart.new(cart_params)
    if @cart.save
      redirect_to @cart, notice: "Cart created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cart.update(cart_params)
      redirect_to @cart, notice: "Cart updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cart.destroy
    redirect_to order_start_path, notice: "Cart deleted.", status: :see_other
  end

  private

  def set_cart
    @cart = Cart.find(params[:id])
  end

  def cart_params
    params.require(:cart).permit(:branch_id)
  end
end
