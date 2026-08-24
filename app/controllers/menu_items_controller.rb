class MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[show edit update destroy]

  def index
    @menu_items = MenuItem.all.order("created_at DESC")
    respond_to do |format|
      format.html # Renders app/views/menu_items/index.html.erb
      format.json { render json: @menu_items } # Renders JSON data
    end
  end

  def show
    # Respond conditionally based on the Accept header
    respond_to do |format|
      format.html
      format.json { render json: @menu_item }
    end
  end

  def new
    @menu_item = MenuItem.new
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)
    if @menu_item.save
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to menu_items_path, notice: "Menu item created." }
        format.json { render json: { status: 200, message: "Menu item created.", item: @menu_item } }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu_item.update(menu_item_params)
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to menu_items_path, notice: "Menu item updated." }
        format.json { render json: { status: 200, message: "Menu item updated.", item: @menu_item } }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    redirect_to menu_items_path, notice: "Menu item deleted.", status: :see_other
  end

  private

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :base_availability)
  end
end
