require File.expand_path('../../test_helper', __FILE__)

class EmailDeliverySettingOfIssueReplyTest < ActiveSupport::TestCase

  fixtures :users, :email_addresses, :user_preferences, :roles,
    :projects, :members, :member_roles, :issues, :issue_statuses,
    :trackers, :enumerations, :custom_fields, :auth_sources, :queries, :workflows,
    :versions, :journals, :journal_details, :projects_trackers,
    :enabled_modules, :boards, :messages, :attachments, :custom_values, :time_entries,
    :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
    :comments

  def setup
    @record = EmailDeliverySettingOfIssueReply.create!(
      project_id: 1, from_address: 'dummy-from@matsukei.co.jp',
      reply_to_address: 'dummy-reply-to@matsukei.co.jp',
      account: 'dummy-user', account_password: 'dummy-password',
      server_address: 'smtp.mail.com', server_port: '587', server_domain: 'example.com',
      server_location: '/usr/local/bin/sendmail', server_arguments: '-i')
  end

  def test_wrap_headers_and_smtp_settings_and_sendmail_settings
    smtp_settings = {
      address: 'smtp.mail.com',
      port: '587',
      domain: 'example.com'
    }
    sendmail_settings = {
      location: '/usr/local/bin/sendmail',
      arguments: '-i'
    }
    expected_values = [
      smtp_settings,
      sendmail_settings,
      smtp_settings,
      sendmail_settings,
      nil, nil, nil, nil
    ]

    [ '0', '1' ].each do |use_settings_of_redmine|
      [ 'smtp', 'sendmail', 'async_smtp', 'async_sendmail' ].each do |delivery_method|
        @record.update(delivery_method: delivery_method,
          use_settings_of_redmine: use_settings_of_redmine)

        settings = @record.wrap_headers
        expected_value = expected_values.shift
        if expected_value.nil?
          assert_not_include :delivery_method, settings.keys
          assert_not_include :delivery_method_options, settings.keys
        else
          assert_equal delivery_method.to_sym, settings[:delivery_method]
          expected_value.each do |expected_key, expected_value|
            assert settings[:delivery_method_options].keys.include?(expected_key)
            assert_equal expected_value, settings[:delivery_method_options][expected_key]
          end
        end

        assert_equal 'dummy-from@matsukei.co.jp', settings['From']
        assert_equal 'dummy-from@matsukei.co.jp', settings['Sender']
        assert_equal '<dummy-from.matsukei.co.jp>', settings['List-Id']
        assert_equal '', settings['X-Redmine-Host']
        assert_equal '', settings['X-Redmine-Site']
      end
    end

  end

  def test_base_settings
    [ '', '0', '1' ].each do |enable_starttls_auto|
      @record.update(enable_starttls_auto: enable_starttls_auto)

      settings = @record.base_settings
      case enable_starttls_auto
        when ''
          assert !settings.key?(:enable_starttls_auto)
        else
          assert_equal enable_starttls_auto == '1', settings[:enable_starttls_auto]
        end
    end
    [ '', 'none', 'peer' ].each do |openssl_verify_mode|
      @record.update(openssl_verify_mode: openssl_verify_mode)

      settings = @record.base_settings
      case openssl_verify_mode
        when ''
          assert !settings.key?(:openssl_verify_mode)
        else
          assert_equal openssl_verify_mode, settings[:openssl_verify_mode]
        end
    end
    [ '', 'plain', 'login', 'cram_md5' ].each do |authentication|
      @record.update(authentication: authentication)

      settings = @record.base_settings
      case authentication
        when ''
          assert !settings.key?(:authentication)
          assert !settings.key?(:user_name)
          assert !settings.key?(:password)
        else
          assert_equal authentication.to_sym, settings[:authentication]
          assert_equal 'dummy-user', settings[:user_name]
          assert_equal 'dummy-password', settings[:password]
        end
    end

  end

end
