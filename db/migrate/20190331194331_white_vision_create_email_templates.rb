class WhiteVisionCreateEmailTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :white_vision_email_templates do |t|
      t.text :format
      t.text :message
      t.text :subject
      t.text :from
      t.boolean "track_success"
      t.text "success_rule"
      t.text "success_url_regexp"
      t.text :status
      t.text :template_id

      t.timestamps
    end
  end
end
