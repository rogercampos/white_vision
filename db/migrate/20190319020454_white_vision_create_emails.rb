class WhiteVisionCreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :white_vision_email_records do |t|
      t.boolean "bounced", null: false, default: false
      t.boolean "dropped", null: false, default: false
      t.boolean "blocked", null: false, default: false
      t.text "drop_reason"
      t.datetime "processed_at"
      t.datetime "delivered_at"
      t.datetime "last_open_at"
      t.datetime "last_click_at"
      t.boolean "success", null: false, default: false
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
      t.index ["recipient"], name: "index_white_vision_emails_on_recipient"
      t.index ["template_id"], name: "index_white_vision_emails_on_template_id"
    end
  end
end
