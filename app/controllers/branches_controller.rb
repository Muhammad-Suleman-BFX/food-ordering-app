class BranchesController < ApplicationController
  before_action :get_branch, only: %i[show edit update destroy menu]

  def index
    @branches = Branch.all.order("created_at DESC")
    respond_to do |format|
      format.html
      format.json { render json: @branches }
    end
  end

  def show
  end

  def new
    @branch = Branch.new
  end

  def create
    @branch = Branch.new(branch_params)
    if @branch.save
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.json { render json: @branch }
        format.html { redirect_to @branch, notice: "Branch created successfully!" }
      end
    else
      render :new, status: 422
    end
  end

  def edit
  end

  def update
    if @branch.update(branch_params)
      # Respond conditionally based on the Accept header
      respond_to do |format|
        format.json { render json: @branch }
        format.html { redirect_to @branch, notice: "Branch updated successfully!" }
      end
    else
      render :edit
    end
  end

  def destroy
    @branch.destroy
    # Respond conditionally based on the Accept header
    respond_to do |format|
      format.json { render json: { status: 200, message: "Branch deleted successfully!" } }
      format.html { redirect_to branches_path, notice: "Branch deleted successfully!" }
    end
  end

  def menu
    @branch_menu_items = @branch.branch_menu_items
                                 .includes(:menu_item)
                                 .where(menu_items: { base_availability: true })
                                 .order("branch_menu_items.created_at DESC")

    @cart = Cart.find_by(id: session[:cart_id])

    # Respond conditionally based on the Accept header
    respond_to do |format|
      format.html
      format.json { render json: @branch_menu_items }
    end
  end

  private

  def get_branch
    @branch = Branch.find(params[:id])
  end

  def branch_params
    params.require(:branch).permit(:name, :address, :latitude, :longitude)
  end
end
