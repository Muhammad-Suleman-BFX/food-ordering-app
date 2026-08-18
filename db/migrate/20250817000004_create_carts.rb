class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.references :branch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
