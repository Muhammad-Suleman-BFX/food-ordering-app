class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[update destroy]

  def create
    cart = Cart.find_by(id: session[:cart_id])

    if cart.nil?
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to order_start_path, alert: "Please start an order first." }
        format.json { render json: { status: 404, message: "Please start an order first." }, status: :not_found }
      end
      return
    end

    branch_menu_item = BranchMenuItem.find(params[:branch_menu_item_id])

    # Check item is available
    unless branch_menu_item.effective_available?
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_back fallback_location: current_cart_path, alert: "This item is not available." }
        format.json { render json: { status: 422, message: "This item is not available." }, status: :unprocessable_entity }
      end
      return
    end

    # Check item belongs to same branch as cart
    if branch_menu_item.branch_id != cart.branch_id
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_back fallback_location: current_cart_path, alert: "This item is not available at the selected branch." }
        format.json { render json: { status: 422, message: "This item is not available at the selected branch." }, status: :unprocessable_entity }
      end
      return
    end

    existing_item = cart.cart_items.find_by(branch_menu_item: branch_menu_item)

    if existing_item
      if existing_item.update(branch_menu_item_quantity: existing_item.branch_menu_item_quantity + 1)
        # Respond conditionally based on the Accept header
        respond_to do |format|
          format.html { redirect_to current_cart_path, notice: "Item quantity updated." }
          format.json { render json: { status: 200, message: "Item quantity updated.", item: existing_item } }
        end
      else
        # Respond conditionally based on the Accept header
        respond_to do |format|
          format.html { redirect_to current_cart_path, alert: existing_item.errors.full_messages.first }
          format.json { render json: { status: 422, message: "Item quantity cannot be updated.", error: existing_item.errors.full_messages.first } }
        end
      end
    else
      cart_item = cart.cart_items.build(branch_menu_item: branch_menu_item, branch_menu_item_quantity: 1)

      if cart_item.save
        # Respond conditionally based on the Accept header
        respond_to do |format|
          format.html { redirect_to current_cart_path, notice: "Item added to cart." }
          format.json { render json: { status: 200, message: "Item added to cart.", item: cart_item } }
        end
      else
        # Respond conditionally based on the Accept header
        respond_to do |format|
          format.html { redirect_back fallback_location: current_cart_path, alert: cart_item.errors.full_messages.first }
          format.json { render json: { status: 422, message: "Item cannot be added to cart.", error: cart_item.errors.full_messages.first } }
        end
      end
    end
  end

  def update
    quantity = params.dig(:cart_item, :branch_menu_item_quantity).to_i

    if quantity <= 0
      @cart_item.destroy
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to current_cart_path, notice: "Item removed from cart." }
        format.json { render json: { status: 200, message: "Item removed from cart.", item: @cart_item } }
      end
    elsif @cart_item.update(branch_menu_item_quantity: quantity)
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to current_cart_path, notice: "Quantity updated." }
        format.json { render json: { status: 200, message: "Quantity updated.", item: @cart_item } }
      end
    else
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to current_cart_path, alert: @cart_item.errors.full_messages.first }
        format.json { render json: { status: 422, message: "Quantity cannot be updated.", error: @cart_item.errors.full_messages.first } }
      end
    end
  end

  def destroy
    @cart_item.destroy
    # Respond conditionally based on the Accept header
    respond_to do |format|
      format.html { redirect_to current_cart_path, notice: "Item removed from cart." }
      format.json { render json: { status: 200, message: "Item removed from cart.", item: @cart_item } }
    end
  end

  private

  def set_cart_item
    @cart_item = CartItem.find(params[:id])
  end
end
