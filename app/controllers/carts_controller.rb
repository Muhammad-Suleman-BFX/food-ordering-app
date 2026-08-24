class CartsController < ApplicationController
  before_action :set_cart, only: %i[show edit update destroy]

  # Show the current active cart from session
  def current
    @cart = Cart.find_by(id: session[:cart_id])

    if @cart.nil?
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to order_start_path, alert: "No active cart. Start an order to begin." }
        format.json { render json: { status: 404, message: "No active cart. Start an order to begin." }, status: :not_found }
      end
      return
    end

    @cart_items = @cart.cart_items.includes(branch_menu_item: :menu_item)
    # @cart_items = @cart.cart_items.includes(branch_menu_item: :menu_item).where(branch_menu_item: { menu_item_availability: true })
    # Respond conditionally based on the Accept header
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @cart }
    end
  end

  def new
    @cart = Cart.new
  end

  def create
    @cart = Cart.new(cart_params)
    if @cart.save
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to @cart, notice: "Cart created." }
        format.json { render json: { status: 200, message: "Cart created.", item: @cart } }
      end
    else
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { status: 422, message: "Cart cannot be created.", error: @cart.errors.full_messages.first } }
      end
    end
  end

  def edit
  end

  def update
    if @cart.update(cart_params)
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to @cart, notice: "Cart updated." }
        format.json { render json: { status: 200, message: "Cart updated.", item: @cart } }
      end
    else
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: 422, message: "Cart cannot be updated.", error: @cart.errors.full_messages.first } }
      end
    end
  end

  def destroy
    @cart.destroy
    session.delete(:cart_id)
    # Respond conditionally based on the Accept header
    respond_to do |format|
      format.html { redirect_to order_start_path, notice: "Cart deleted.", status: :see_other }
      format.json { render json: { status: 200, message: "Cart deleted.", item: @cart } }
    end
  end

  private

  def set_cart
    @cart = Cart.find(params[:id])
  end

  def cart_params
    params.require(:cart).permit(:branch_id)
  end
end
