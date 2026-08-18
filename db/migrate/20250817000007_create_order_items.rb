class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true

      t.string :menu_item_name, null: false
      t.decimal :menu_item_price, precision: 10, scale: 2, null: false
      t.integer :menu_item_quantity, null: false, default: 1

      t.timestamps
    end

    # Will see later whether we need to add index for menu_item_name or not.
    # add_index :order_items, :menu_item_name
  end
end
