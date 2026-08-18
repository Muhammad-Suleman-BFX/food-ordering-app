class MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[show edit update destroy]

  def index
    @menu_items = MenuItem.all.order(:created_at)
    respond_to do |format|
      format.html # Renders app/views/menu_items/index.html.erb
      format.json { render json: @menu_items } # Renders JSON data
    end
  end

  def show
  end

  def new
    @menu_item = MenuItem.new
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)
    if @menu_item.save
      redirect_to @menu_item, notice: "Menu item created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu_item.update(menu_item_params)
      redirect_to @menu_item, notice: "Menu item updated."
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
