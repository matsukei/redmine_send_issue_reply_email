class CreateEmailAddressOfIssueReplies < ActiveRecord::Migration
  def change
    create_table :email_address_of_issue_replies do |t|
      t.integer :issue_id, null: false

      t.string :subject
      t.string :to_addresses
      t.string :cc_addresses

      t.timestamps
    end
  end
end
