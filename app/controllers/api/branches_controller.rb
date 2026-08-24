module Api
  class BranchesController < BaseController
    def index
      branches = Branch.order(:name)
      render json: branches.map { |b| branch_json(b) }
    end

    def nearest
      latitude = params[:latitude]
      longitude = params[:longitude]

      if latitude.blank? || longitude.blank?
        render json: { error: "Both latitude and longitude are required" }, status: :bad_request
        return
      end

      lat = latitude.to_f
      lng = longitude.to_f

      nearest_branch = Branch.order(Arel.sql("ABS(latitude - #{lat}) + ABS(longitude - #{lng})")).first

      if nearest_branch.nil?
        render json: { error: "No branches are available" }, status: :unprocessable_entity
        return
      end

      render json: branch_json(nearest_branch)
    end

    def menu
      branch = Branch.find(params[:id])
      items = branch.branch_menu_items
                    .includes(:menu_item)
                    .where(menu_items: { base_availability: true })
                    .order("branch_menu_items.created_at DESC")

      render json: items.map { |bmi| menu_item_json(bmi) }
    end

    private

    def branch_json(branch)
      {
        id: branch.id,
        name: branch.name,
        address: branch.address,
        latitude: branch.latitude.to_s,
        longitude: branch.longitude.to_s
      }
    end

    def menu_item_json(bmi)
      {
        id: bmi.id,
        menu_item_id: bmi.menu_item_id,
        name: bmi.menu_item.name,
        description: bmi.menu_item.description,
        price: money(bmi.menu_item_price),
        available: bmi.effective_available?
      }
    end
  end
end
