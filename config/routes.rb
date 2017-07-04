RedmineApp::Application.routes.draw do
  match 'projects/:id/email_delivery_setting_of_issue_reply', to: 'email_delivery_setting_of_issue_replies#edit', via: :post
  match 'email_delivery_setting_of_issue_reply/:id/test_email', to: 'email_delivery_setting_of_issue_replies#test_email', via: :post
end
