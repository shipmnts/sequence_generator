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

ActiveRecord::Schema.define(version: 2020_04_12_133917) do

  create_table "sequence_generator_current_sequences", force: :cascade do |t|
    t.string "name", null: false
    t.integer "current", default: 1, null: false
    t.string "scope", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sequence_generator_sequences", force: :cascade do |t|
    t.string "sequence_prefix"
    t.integer "sequential_id"
    t.integer "start_at"
    t.date "valid_from"
    t.date "valid_till"
    t.boolean "reset_from_next_year"
    t.string "purpose"
    t.integer "financial_year_start"
    t.integer "financial_year_end"
    t.string "scope"
    t.string "max_prefix_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "some_models", force: :cascade do |t|
    t.string "name"
    t.integer "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
