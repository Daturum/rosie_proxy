# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_05_17_102737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rosie_asset_files", force: :cascade do |t|
    t.string "filename"
    t.string "content_type"
    t.binary "file_contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "size"
    t.boolean "autoreplace_filepaths"
  end

  create_table "rosie_components", force: :cascade do |t|
    t.string "component_type"
    t.string "path"
    t.string "locale"
    t.string "handler"
    t.boolean "partial"
    t.string "format"
    t.string "editing_locked_by"
    t.text "body"
    t.text "loading_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rosie_programmers", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
