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
      redirect_to @branch
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @branch.update(branch_params)
      redirect_to @branch
    else
      render :edit
    end
  end

  def destroy
    @branch.destroy
    redirect_to branches_path
  end

  def menu
    @branch_menu_items = @branch.branch_menu_items
                                 .includes(:menu_item)
                                 .where(menu_items: { base_availability: true })
                                 .order("branch_menu_items.created_at DESC")

    @cart = Cart.find_by(id: session[:cart_id])
  end

  private

  def get_branch
    @branch = Branch.find(params[:id])
  end

  def branch_params
    params.require(:branch).permit(:name, :address, :latitude, :longitude)
  end
end
