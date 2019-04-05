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

ActiveRecord::Schema.define(version: 2019_03_31_194331) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "white_vision_email_records", force: :cascade do |t|
    t.boolean "bounced", default: false, null: false
    t.boolean "dropped", default: false, null: false
    t.boolean "blocked", default: false, null: false
    t.text "drop_reason"
    t.datetime "processed_at"
    t.datetime "delivered_at"
    t.datetime "last_open_at"
    t.datetime "last_click_at"
    t.boolean "success", default: false, null: false
    t.boolean "track_success", null: false
    t.text "success_rule"
    t.text "success_url_regexp"
    t.text "recipient", null: false
    t.text "subject", null: false
    t.integer "total_opens", default: 0
    t.integer "total_clicks", default: 0
    t.datetime "first_open_at"
    t.datetime "first_click_at"
    t.text "last_open_from_ip"
    t.text "template_id"
    t.text "last_open_from_country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "extra_data"
    t.index ["recipient"], name: "index_emails_on_recipient"
    t.index ["template_id"], name: "index_emails_on_template_id"
  end

  create_table "white_vision_email_templates", force: :cascade do |t|
    t.text "format"
    t.text "message"
    t.text "subject"
    t.text "from"
    t.boolean "track_success"
    t.text "success_rule"
    t.text "success_url_regexp"
    t.text "status"
    t.text "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
