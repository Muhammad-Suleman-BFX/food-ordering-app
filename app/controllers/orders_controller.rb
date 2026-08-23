class OrdersController < ApplicationController
  before_action :get_branches, only: %i[start]
  before_action :set_order, only: %i[show edit update destroy]

  def index
    @orders = Order.includes(:branch, :order_items).order(created_at: :desc)
  end

  def show
  end

  # Step 1: Start order - select type and branch
  def start
  end

  # Step 2: Process start form - create cart and go to menu
  def set_branch
    order_type = params[:order_type]
    branch_id  = params[:branch_id]
    latitude   = params[:latitude]&.strip
    longitude  = params[:longitude]&.strip

    # Validate order type
    if order_type.blank?
      flash.now[:alert] = "Please select an order type (Pickup or Delivery)."
      render :start, status: :unprocessable_entity
      return
    end

    # Validate branch or GPS
    if branch_id.blank? && (latitude.blank? || longitude.blank?)
      flash.now[:alert] = "Please select a branch or enter both latitude and longitude."
      render :start, status: :unprocessable_entity
      return
    end

    # If GPS provided but no branch, find nearest branch
    if branch_id.blank? && latitude.present? && longitude.present?
      lat = latitude.to_f
      lng = longitude.to_f
      # Quick, flat-earth calculation
      # Else we can use Geocoder Gem as it calculates distances taking into Earth's curvature
      nearest_branch = Branch.order(Arel.sql("ABS(latitude - #{lat}) + ABS(longitude - #{lng})")).first

      if nearest_branch.nil?
        flash.now[:alert] = "No branches are available. Please try again later."
        render :start, status: :unprocessable_entity
        return
      end

      branch_id = nearest_branch.id
    end

    # Clear any existing cart session
    session.delete(:cart_id)
    session.delete(:order_type)

    # Create a new cart for this branch
    cart = Cart.create!(branch_id: branch_id)
    session[:cart_id] = cart.id
    session[:order_type] = order_type

    redirect_to menu_branch_path(branch_id), notice: "Cart started. Browse the menu and add items."
  end

  # Step 3: Place order from cart
  def place
    cart = Cart.find_by(id: session[:cart_id])

    if cart.nil?
      redirect_to order_start_path, alert: "No active cart. Please start an order first."
      return
    end

    if cart.cart_items.empty?
      redirect_to current_cart_path, alert: "Your cart is empty. Add items before placing an order."
      return
    end

    # Re-check availability at order time (items may have become unavailable)
    if cart.cart_items.any? { |ci| !ci.branch_menu_item.effective_available? }
      redirect_to current_cart_path, alert: "Some items in your cart are no longer available. Please review your cart."
      return
    end

    order_type = session[:order_type] || "pickup"

    @order = Order.new(
      branch: cart.branch,
      order_type: order_type,
      status: :pending
    )

    # Build order items from cart items (price snapshot)
    cart.cart_items.each do |cart_item|
      @order.order_items.build(
        menu_item_name: cart_item.branch_menu_item.menu_item.name,
        menu_item_price: cart_item.branch_menu_item.menu_item_price,
        menu_item_quantity: cart_item.branch_menu_item_quantity
      )
    end

    @order.total_price = @order.order_items.sum { |oi| oi.menu_item_price * oi.menu_item_quantity }

    # Wrap order creation and cart cleanup in a transaction
    ActiveRecord::Base.transaction do
      if @order.save
        # Clear cart and session
        cart.destroy
        session.delete(:cart_id)
        session.delete(:order_type)

        redirect_to @order, notice: "Order placed successfully!"
      else
        redirect_to current_cart_path, alert: "Could not place order: #{@order.errors.full_messages.first}"
      end
    end
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      redirect_to @order, notice: "Order created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: "Order updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_path, notice: "Order deleted.", status: :see_other
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def get_branches
    @branches = Branch.order(:name)
  end

  def order_params
    params.require(:order).permit(:branch_id, :order_type, :status, :total_price)
  end
end
