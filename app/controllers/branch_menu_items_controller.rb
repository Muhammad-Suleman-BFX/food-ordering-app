class BranchMenuItemsController < ApplicationController
  before_action :get_branch, only: %i[ new create edit update ]
  before_action :get_branch_menu_item, only: %i[ destroy edit update ]
  before_action :get_branch_menu_items, only: %i[ index show ]
  before_action :get_available_menu_items, only: %i[ new create edit update ]

  def index
    respond_to do |format|
      format.html # Renders app/views/branch_menu_items/index.html.erb
      format.json { render json: @branch_menu_items } # Renders JSON data
    end
  end

  def show
  end

  def new
    @branch_menu_item = BranchMenuItem.new()
  end

  def create
    @branch_menu_item = @branch.branch_menu_items.build(branch_menu_item_params)
    if @branch_menu_item.save
      redirect_to branch_menu_path, notice: "Branch menu item created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @branch_menu_item.update(branch_menu_item_params)
      redirect_to branch_menu_path, notice: "Branch menu item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @branch_menu_item.destroy
    redirect_to branch_menu_path, notice: "Branch menu item deleted.", status: :see_other
  end

  private
  def get_branch
    @branch = Branch.find(params[:branch_id])
  end

  def get_branch_menu_item
    @branch_menu_item = BranchMenuItem.find(params[:id])
  end

  def get_available_menu_items
    @available_menu_items = MenuItem.where(base_availability: true)
  end

  def get_branch_menu_items
    @branch_menu_items = BranchMenuItem.where(branch_id: params[:branch_id]).order("created_at DESC")
  end

  def branch_menu_item_params
    params.require(:branch_menu_item).permit(:branch_id, :menu_item_id, :menu_item_price, :menu_item_availability)
  end
end
