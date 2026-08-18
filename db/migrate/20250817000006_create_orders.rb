class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :branch, null: false, foreign_key: true

      t.integer :type, null: false, default: 0 # { pickup: 0, delivery: 1 }
      t.integer :status, null: false, default: 0 # { pending, confirmed, preparing, ready, out_for_delivery, completed, cancelled }
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end

    # Will see later whether we need to add indexes for type, status, and total_price or not.
    # add_index :orders, :type
    # add_index :orders, :status
    # add_index :orders, :total_price
  end
end
