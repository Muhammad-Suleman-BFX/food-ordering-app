class BranchesController < ApplicationController
  before_action :get_branch, only: %i[ show edit update destroy]
  def index
    @branches = Branch.all
    respond_to do |format|
      format.html # Renders app/views/branches/index.html.erb
      format.json { render json: @branches } # Renders JSON data
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

  private
    def get_branch
      @branch = Branch.find(params[:id])
    end

    def branch_params
      params.require(:branch).permit(:name, :address, :latitude, :longitude)
    end
end
