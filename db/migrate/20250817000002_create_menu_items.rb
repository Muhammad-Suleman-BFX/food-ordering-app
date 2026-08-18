class CreateMenuItems < ActiveRecord::Migration[7.1]
  def change
    create_table :menu_items do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :base_availability, default: false, null: false

      t.timestamps
    end

    # Will see later whether we need to add index for menu_items or not.
    # add_index :menu_items, :name
  end
end
