class RenameQuantityToBranchMenuItemQuantityInCartItems < ActiveRecord::Migration[7.1]
  def change
    rename_column :cart_items, :quantity, :branch_menu_item_quantity
  end
end
