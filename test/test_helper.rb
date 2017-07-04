# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

def expected_values_on_create_email_delivery_setting
  {
    project_id: 1,
    from_address: 'dummy-from1@matsukei.co.jp',
    reply_to_address: 'dummy-reply-to1@matsukei.co.jp',
    plain_text: '1',
    header: 'emails-header1',
    footer: 'emails-footer1',
    use_settings_of_redmine: '1',
    delivery_method: 'async_sendmail',
    server_location: '/usr/local/bin/sendmail',
    server_arguments: '-i',
    enable_starttls_auto: '1',
    openssl_verify_mode: 'peer',
    server_address: '127.0.0.1',
    server_port: '25',
    server_domain: 'example.net',
    authentication: 'login',
    account: 'redmine@example.net',
    account_password: 'redmine',
    default_send_email: '0'
  }
end

def expected_values_on_changed_update_email_delivery_setting
  {
    project_id: 1,
    from_address: 'dummy-from2@matsukei.co.jp',
    reply_to_address: 'dummy-reply-to2@matsukei.co.jp',
    plain_text: '0',
    header: 'emails-header2',
    footer: 'emails-footer2',
    use_settings_of_redmine: '0',
    delivery_method: 'smtp',
    server_location: '/usr/sbin/sendmail',
    server_arguments: '-I',
    enable_starttls_auto: '0',
    openssl_verify_mode: 'none',
    server_address: 'smtp.mail.com',
    server_port: '587',
    server_domain: 'example.com',
    authentication: 'plain',
    account: 'redmine@example.com',
    account_password: 'password',
    default_send_email: '1'
  }
end

def expected_values_on_blank_update_email_delivery_setting
  {
    project_id: 1,
    from_address: 'dummy-from@matsukei.co.jp',
    reply_to_address: 'dummy-reply-to@matsukei.co.jp',
    plain_text: '',
    header: '',
    footer: '',
    use_settings_of_redmine: '',
    delivery_method: '',
    server_location: '',
    server_arguments: '',
    enable_starttls_auto: '',
    openssl_verify_mode: '',
    server_address: '',
    server_port: '',
    server_domain: '',
    authentication: '',
    account: '',
    account_password: '',
    default_send_email: ''
  }
end

def assert_email_delivery_setting_edit_expected_values(expected_values, record)
  assert_response :success
  assert_equal 'text/javascript', response.content_type
  assert_not_include 'cannot be blank', response.body
  assert_not_include 'is invalid', response.body
  assert_include 'Send a test email', response.body

  expected_values.each do |attr, value|
    assert_equal value, record.public_send(attr)
  end
end

def generate_email_delivery_setting_of_same_redmine(project)
  EmailDeliverySettingOfIssueReply.create!(project_id: project.id,
    from_address: 'dummy-from@matsukei.co.jp',
    reply_to_address: 'dummy-reply-to@matsukei.co.jp',
    header: "Header first line\r\n*Header second line*\r\nHeader third line",
    footer: "Footer first line\r\n*Footer second line*\r\nFooter third line",
    use_settings_of_redmine: true)
end

class DummyMail
  include ActiveModel::Model

  attr_accessor :from, :reply_to, :to, :cc
end

def last_email
  ActionMailer::Base.deliveries.last
end
