class CreateBranchMenuItems < ActiveRecord::Migration[7.1]
  def change
    create_table :branch_menu_items do |t|
      t.references :branch, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true

      t.boolean :menu_item_availability, default: true, null: false
      t.decimal :menu_item_price, precision: 10, scale: 2, null: false
      t.check_constraint "menu_item_price > 0", name: "menu_item_price_numeric_positive"

      t.timestamps
    end

    add_index :branch_menu_items, [ :branch_id, :menu_item_id ], unique: true
  end
end
