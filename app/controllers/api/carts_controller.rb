module Api
  class CartsController < BaseController
    before_action :set_cart, only: %i[show checkout]

    def create
      cart = Cart.new(cart_params)
      if cart.save
        render json: cart_json(cart), status: :created
      else
        render_validation_error(cart)
      end
    end

    def show
      render json: cart_json(@cart)
    end

    def checkout
      if @cart.cart_items.empty?
        render json: { error: "Your cart is empty. Add items before placing an order." }, status: :unprocessable_entity
        return
      end

      if @cart.cart_items.any? { |ci| !ci.branch_menu_item.effective_available? }
        render json: { error: "Some items in your cart are no longer available. Please review your cart." }, status: :unprocessable_entity
        return
      end

      order = Order.new(
        branch: @cart.branch,
        order_type: @cart.order_type,
        status: :pending
      )

      @cart.cart_items.each do |cart_item|
        order.order_items.build(
          menu_item_name: cart_item.branch_menu_item.menu_item.name,
          menu_item_price: cart_item.branch_menu_item.menu_item_price,
          menu_item_quantity: cart_item.branch_menu_item_quantity
        )
      end

      order.total_price = order.order_items.sum { |oi| oi.menu_item_price * oi.menu_item_quantity }

      ActiveRecord::Base.transaction do
        if order.save
          @cart.destroy
          render json: order_json(order), status: :created
        else
          render_validation_error(order)
        end
      end
    end

    private

    def set_cart
      @cart = Cart.find(params[:id])
    end

    def cart_params
      params.require(:cart).permit(:branch_id, :order_type)
    end

    def cart_json(cart)
      {
        id: cart.id,
        branch_id: cart.branch_id,
        branch_name: cart.branch.name,
        order_type: cart.order_type,
        items: cart.cart_items.includes(branch_menu_item: :menu_item).map { |ci| cart_item_json(ci) },
        total_price: money(cart.total_price),
        total_items_count: cart.total_items_count
      }
    end

    def cart_item_json(cart_item)
      bmi = cart_item.branch_menu_item
      {
        id: cart_item.id,
        branch_menu_item_id: bmi.id,
        name: bmi.menu_item.name,
        price: money(bmi.menu_item_price),
        quantity: cart_item.branch_menu_item_quantity,
        line_total: money(bmi.menu_item_price * cart_item.branch_menu_item_quantity)
      }
    end

    def order_json(order)
      {
        id: order.id,
        branch_id: order.branch_id,
        order_type: order.order_type,
        status: order.status,
        total_price: money(order.total_price),
        order_items: order.order_items.map do |oi|
          {
            menu_item_name: oi.menu_item_name,
            menu_item_price: money(oi.menu_item_price),
            menu_item_quantity: oi.menu_item_quantity
          }
        end
      }
    end
  end
end
