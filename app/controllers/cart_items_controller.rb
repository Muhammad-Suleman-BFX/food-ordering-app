class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[update destroy]

  def create
    cart = Cart.find_by(id: session[:cart_id])

    if cart.nil?
      redirect_to order_start_path, alert: "Please start an order first."
      return
    end

    branch_menu_item = BranchMenuItem.find(params[:branch_menu_item_id])

    # Check item is available
    unless branch_menu_item.effective_available?
      redirect_back fallback_location: current_cart_path, alert: "This item is not available."
      return
    end

    # Check item belongs to same branch as cart
    if branch_menu_item.branch_id != cart.branch_id
      redirect_back fallback_location: current_cart_path, alert: "This item is not available at the selected branch."
      return
    end

    existing_item = cart.cart_items.find_by(branch_menu_item: branch_menu_item)

    if existing_item
      if existing_item.update(branch_menu_item_quantity: existing_item.branch_menu_item_quantity + 1)
        redirect_to current_cart_path, notice: "Item quantity updated."
      else
        redirect_to current_cart_path, alert: existing_item.errors.full_messages.first
      end
    else
      cart_item = cart.cart_items.build(branch_menu_item: branch_menu_item, branch_menu_item_quantity: 1)

      if cart_item.save
        redirect_to current_cart_path, notice: "Item added to cart."
      else
        redirect_back fallback_location: current_cart_path, alert: cart_item.errors.full_messages.first
      end
    end
  end

  def update
    quantity = params.dig(:cart_item, :branch_menu_item_quantity).to_i

    if quantity <= 0
      @cart_item.destroy
      redirect_to current_cart_path, notice: "Item removed from cart."
    elsif @cart_item.update(branch_menu_item_quantity: quantity)
      redirect_to current_cart_path, notice: "Quantity updated."
    else
      redirect_to current_cart_path, alert: @cart_item.errors.full_messages.first
    end
  end

  def destroy
    @cart_item.destroy
    redirect_to current_cart_path, notice: "Item removed from cart."
  end

  private

  def set_cart_item
    @cart_item = CartItem.find(params[:id])
  end
end
