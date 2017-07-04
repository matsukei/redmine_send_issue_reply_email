require File.expand_path('../../test_helper', __FILE__)

class IssueReplyMailerTest < ActiveSupport::TestCase
  include Redmine::I18n
  include Rails::Dom::Testing::Assertions

  fixtures :users, :email_addresses, :user_preferences, :roles,
    :projects, :members, :member_roles, :issues, :issue_statuses,
    :trackers, :enumerations, :custom_fields, :auth_sources, :queries, :workflows,
    :versions, :journals, :journal_details, :projects_trackers,
    :enabled_modules, :boards, :messages, :attachments, :custom_values, :time_entries,
    :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
    :comments

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.plain_text_mail = '0'
    Setting.bcc_recipients = '1'
    Setting.default_language = 'en'
    User.current = nil
  end

  def test_notification
    # See: test/functional/issues_controller_test.rb#test_valid_edit_with_send_email_on
    # Journal ID 3 has an attached file. However, since there is no real file, it can not be tested.
  end

  def test_email_addresses_should_empty_bcc_with_bcc_recipients_off
    issue = Issue.find(1)
    journal = Journal.find(1)
    email = DummyMail.new(from: [ 'dummy-from@customer.co.jp' ],
      reply_to: nil, to: [ 'dummy-to@matsukei.co.jp' ],
      cc: [ 'dummy-cc-1@matsukei.co.jp', 'dummy-cc-2@matsukei.co.jp' ])
    EmailAddressOfIssueReply.create_by_received_mail(issue.id, email)

    project = Project.find(1)
    email_delivery_setting = generate_email_delivery_setting_of_same_redmine(project)
    email_delivery_setting.update(plain_text: true)

    with_settings bcc_recipients: 0 do
      assert IssueReplyMailer.notification(issue.reload, journal).deliver
      mail = last_email
      # to: from + to or reply_to
      assert_equal [ 'dummy-from@customer.co.jp', 'dummy-to@matsukei.co.jp' ], mail.to.to_a
      # cc: no change
      assert_equal [ 'dummy-cc-1@matsukei.co.jp', 'dummy-cc-2@matsukei.co.jp' ], mail.cc.to_a
      # bcc: empty
      assert_equal [], mail.bcc.to_a
      assert_equal mail.subject, '[Re: #1] ' + issue.subject
      assert_include "Journal notes", mail.body.decoded
    end
  end

  def test_email_addresses_should_empty_bcc_with_bcc_recipients_on
    issue = Issue.find(1)
    journal = Journal.find(1)
    email = DummyMail.new(from: [ 'dummy-from@customer.co.jp' ],
      reply_to: [ 'dummy-reply-to@customer.co.jp' ], to: [ 'dummy-to@matsukei.co.jp' ],
      cc: [ 'dummy-cc-1@matsukei.co.jp', 'dummy-cc-2@matsukei.co.jp' ])
    EmailAddressOfIssueReply.create_by_received_mail(issue.id, email)

    project = Project.find(1)
    email_delivery_setting = generate_email_delivery_setting_of_same_redmine(project)
    email_delivery_setting.update(plain_text: true)

    with_settings bcc_recipients: 1 do
      assert IssueReplyMailer.notification(issue.reload, journal).deliver
      mail = last_email
      # to: from + to or reply_to
      assert_equal [ 'dummy-reply-to@customer.co.jp' ], mail.to.to_a
      # cc: no change
      assert_equal [ 'dummy-cc-1@matsukei.co.jp', 'dummy-cc-2@matsukei.co.jp' ], mail.cc.to_a
      # bcc: empty
      assert_equal [], mail.bcc.to_a
      assert_equal mail.subject, '[Re: #1] ' + issue.subject
      assert_include "Journal notes", mail.body.decoded
    end
  end

  def test_layout_should_include_header_and_footer
    project = Project.find(1)
    email_delivery_setting = generate_email_delivery_setting_of_same_redmine(project)

    email_delivery_setting.update(plain_text: false)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    assert_select_email do
      assert_select ".header" do
        assert_select "strong", text: "Header second line"
      end
      assert_select "p", text: "Comments are written here(HTML format)."
      assert_select ".footer" do
        assert_select "strong", text: "Footer second line"
      end
    end

    email_delivery_setting.update(plain_text: true)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    mail = last_email
    assert_equal [ 'jsmith@somenet.foo' ], mail.to.to_a
    assert_equal [], mail.cc.to_a
    assert_equal [], mail.bcc.to_a
    assert_include "*Header second line*", mail.body.decoded
    assert_include "Comments are written here(Plain text format).", mail.body.decoded
    assert_include "*Footer second line*", mail.body.decoded
  end

  def test_layout_should_not_include_empty_header_and_footer
    project = Project.find(1)
    email_delivery_setting = generate_email_delivery_setting_of_same_redmine(project)
    email_delivery_setting.update(header: '')
    email_delivery_setting.update(footer: '')

    email_delivery_setting.update(plain_text: false)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    assert_select_email do
      assert_select ".header", false
      assert_select "p", text: "Comments are written here(HTML format)."
      assert_select ".footer", false
    end
    email_delivery_setting.update(plain_text: true)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    mail = last_email
    assert_equal [ 'jsmith@somenet.foo' ], mail.to.to_a
    assert_equal [], mail.cc.to_a
    assert_equal [], mail.bcc.to_a
    assert_not_include "*Header second line*", mail.body.decoded
    assert_include "Comments are written here(Plain text format).", mail.body.decoded
    assert_not_include "*Footer second line*", mail.body.decoded
  end

  def test_layout_should_include_the_emails_header
    project = Project.find(1)
    email_delivery_setting = generate_email_delivery_setting_of_same_redmine(project)
    email_delivery_setting.update(footer: '')

    email_delivery_setting.update(plain_text: false)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    assert_select_email do
      assert_select ".header" do
        assert_select "strong", text: "Header second line"
      end
      assert_select "p", text: "Comments are written here(HTML format)."
      assert_select ".footer", false
    end
    email_delivery_setting.update(plain_text: true)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    mail = last_email
    assert_equal [ 'jsmith@somenet.foo' ], mail.to.to_a
    assert_equal [], mail.cc.to_a
    assert_equal [], mail.bcc.to_a
    assert_include "*Header second line*", mail.body.decoded
    assert_include "Comments are written here(Plain text format).", mail.body.decoded
    assert_not_include "*Footer second line*", mail.body.decoded
  end

  def test_layout_should_include_the_emails_footer
    project = Project.find(1)
    email_delivery_setting = generate_email_delivery_setting_of_same_redmine(project)
    email_delivery_setting.update(header: '')

    email_delivery_setting.update(plain_text: false)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    assert_select_email do
      assert_select ".header", false
      assert_select "p", text: "Comments are written here(HTML format)."
      assert_select ".footer" do
        assert_select "strong", text: "Footer second line"
      end
    end
    email_delivery_setting.update(plain_text: true)
    assert IssueReplyMailer.test_email(User.find(2), project.reload).deliver
    mail = last_email
    assert_equal [ 'jsmith@somenet.foo' ], mail.to.to_a
    assert_equal [], mail.cc.to_a
    assert_equal [], mail.bcc.to_a
    assert_not_include "*Header second line*", mail.body.decoded
    assert_include "Comments are written here(Plain text format).", mail.body.decoded
    assert_include "*Footer second line*", mail.body.decoded
  end

end
