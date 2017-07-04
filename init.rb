Redmine::Plugin.register :redmine_send_issue_reply_email do
  name 'Redmine Send Issue Reply Email'
  author 'Matsukei Co.,Ltd'
  description 'It is a plugin that provides the email sending feature to non Redmine users when registering notes.'
  version '1.0.0'
  requires_redmine version_or_higher: '3.2.0'
  url 'https://github.com/matsukei/redmine_send_issue_reply_email'
  author_url 'http://www.matsukei.co.jp/'

  project_module :send_issue_reply_email do
    permission :manage_email_delivery_setting, {
      email_delivery_setting_of_issue_replies: [
        :edit, :test_email
      ]
    }, require: :member
  end

end

require_relative 'lib/send_issue_reply_email'
