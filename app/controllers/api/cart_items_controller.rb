module Api
  class CartItemsController < BaseController
    before_action :get_cart, only: %i[create]
    before_action :get_cart_item, only: %i[update destroy]

    def create
      branch_menu_item = BranchMenuItem.find(params[:branch_menu_item_id])

      unless branch_menu_item.effective_available?
        render json: { error: "This item is not available." }, status: :unprocessable_entity
        return
      end

      if branch_menu_item.branch_id != @cart.branch_id
        render json: { error: "This item is not available at the selected branch." }, status: :unprocessable_entity
        return
      end

      existing_item = @cart.cart_items.find_by(branch_menu_item: branch_menu_item)

      if existing_item
        if existing_item.update(branch_menu_item_quantity: existing_item.branch_menu_item_quantity + 1)
          render json: cart_item_json(existing_item), status: :ok
        else
          render_validation_error(existing_item)
        end
      else
        cart_item = @cart.cart_items.build(
          branch_menu_item: branch_menu_item,
          branch_menu_item_quantity: 1
        )

        if cart_item.save
          render json: cart_item_json(cart_item), status: :created
        else
          render_validation_error(cart_item)
        end
      end
    end

    def update
      quantity = params[:quantity].to_i

      if quantity <= 0
        render json: { error: "Quantity must be greater than 0. Use DELETE to remove the item." }, status: :unprocessable_entity
        return
      end

      if @cart_item.update(branch_menu_item_quantity: quantity)
        render json: cart_item_json(@cart_item)
      else
        render_validation_error(@cart_item)
      end
    end

    def destroy
      @cart_item.destroy
      head :no_content
    end

    private

    def get_cart
      @cart = Cart.find(params[:cart_id])
    end

    def get_cart_item
      @cart = Cart.find(params[:cart_id])
      @cart_item = @cart.cart_items.find(params[:id])
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
  end
end
