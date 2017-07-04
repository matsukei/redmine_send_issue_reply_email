class CreateEmailDeliverySettingOfIssueReplies < ActiveRecord::Migration
  def change
    create_table :email_delivery_setting_of_issue_replies do |t|
      t.integer :project_id

      t.boolean :default_send_email, default: false

      t.string :from_address
      t.string :reply_to_address

      t.boolean :plain_text, default: false
      t.text :header
      t.text :footer

      t.boolean :use_settings_of_redmine, default: false
      t.string :delivery_method

      t.string :server_location
      t.string :server_arguments

      t.string :enable_starttls_auto
      t.string :openssl_verify_mode

      t.string :server_address
      t.string :server_port
      t.string :server_domain

      t.string :authentication
      t.string :account
      t.string :account_password

      t.timestamps
    end
  end
end
