class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
      t.string :name, null: false
      t.text :address, null: false
      t.decimal :latitude, precision: 10, scale: 8, null: false
      t.decimal :longitude, precision: 11, scale: 8, null: false

      t.timestamps
    end

    # Will see later whether we need to add index for latitude and longitude or not.
    # add_index :branches, [ :latitude, :longitude ]
  end
end
