class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :branch_menu_item, null: false, foreign_key: true

      t.integer :branch_menu_item_quantity, null: false, default: 1

      t.timestamps
    end

    add_index :cart_items, [ :cart_id, :branch_menu_item_id ], unique: true
  end
end
