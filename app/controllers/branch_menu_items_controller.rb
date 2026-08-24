class BranchMenuItemsController < ApplicationController
  before_action :get_branch, only: %i[ new create edit update destroy ]
  before_action :get_available_menu_items, only: %i[ new create edit update ]
  before_action :get_branch_menu_item, only: %i[ show edit update destroy ]

  def new
    @branch_menu_item = BranchMenuItem.new(branch_id: @branch.id)
  end

  def create
    @branch_menu_item = BranchMenuItem.new(branch_menu_item_params.merge(branch_id: @branch.id))
    if @branch_menu_item.save
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to menu_branch_path(@branch.id), notice: "Branch menu item created." }
        format.json { render json: { message: "Branch menu item created.", item: @branch_menu_item }, status: 200 }
      end
    else
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { message: "Branch menu item cannot be created.", error: @branch_menu_item.errors.full_messages.first }, status: 422 }
      end
    end
  end

  def edit
  end

  def update
    if @branch_menu_item.update(branch_menu_item_params)
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to menu_branch_path(@branch.id), notice: "Branch menu item updated." }
        format.json { render json: { message: "Branch menu item updated.", item: @branch_menu_item }, status: 200 }
      end
    else
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { message: "Branch menu item cannot be updated.", error: @branch_menu_item.errors.full_messages.first }, status: 422 }
      end
    end
  end

  def destroy
    if @branch_menu_item.destroy
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to menu_branch_path(@branch.id), notice: "Branch menu item deleted.", status: :see_other }
        format.json { render json: { message: "Branch menu item deleted.", item: @branch_menu_item }, status: 200 }
      end
    else
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.html { redirect_to menu_branch_path(@branch.id), alert: @branch_menu_item.errors.full_messages.to_sentence, status: :see_other }
        format.json { render json: { message: "Branch menu item cannot be updated.", error: @branch_menu_item.errors.full_messages.to_sentence }, status: 422 }
      end
    end
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

  def branch_menu_item_params
    params.require(:branch_menu_item).permit(:branch_id, :menu_item_id, :menu_item_price, :menu_item_availability)
  end
end
