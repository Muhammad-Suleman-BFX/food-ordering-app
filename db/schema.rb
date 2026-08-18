# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_08_17_000005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "branch_menu_items", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "menu_item_id", null: false
    t.boolean "menu_item_availability", default: true, null: false
    t.decimal "menu_item_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "menu_item_id"], name: "index_branch_menu_items_on_branch_id_and_menu_item_id", unique: true
    t.index ["branch_id"], name: "index_branch_menu_items_on_branch_id"
    t.index ["menu_item_id"], name: "index_branch_menu_items_on_menu_item_id"
    t.check_constraint "menu_item_price > 0::numeric", name: "menu_item_price_numeric_positive"
  end

  create_table "branches", force: :cascade do |t|
    t.string "name", null: false
    t.text "address", null: false
    t.decimal "latitude", precision: 10, scale: 8, null: false
    t.decimal "longitude", precision: 11, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "branch_menu_item_id", null: false
    t.integer "branch_menu_item_quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_menu_item_id"], name: "index_cart_items_on_branch_menu_item_id"
    t.index ["cart_id", "branch_menu_item_id"], name: "index_cart_items_on_cart_id_and_branch_menu_item_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_carts_on_branch_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "base_availability", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "branch_menu_items", "branches"
  add_foreign_key "branch_menu_items", "menu_items"
  add_foreign_key "cart_items", "branch_menu_items"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "carts", "branches"
end
