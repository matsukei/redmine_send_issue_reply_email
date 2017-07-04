require File.expand_path('../../test_helper', __FILE__)

class SendIssueReplyEmail::IssuesControllerTest < ActionController::TestCase
  tests IssuesController

  include Redmine::I18n

  def setup
    ActionMailer::Base.deliveries.clear
    # User: jsmith
    @request.session[:user_id] = 2
    Setting.default_language = 'en'
    # Project: ecookbook
    @project = Project.find(1)
  end

  # projects/ecookbook/issues/new
  def test_get_new_with_enable_module_and_have_record
    @project.enable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)

    get :new, { project_id: 1 }
    assert_response :success
    assert_select 'div#email-addresses', false
    assert @project.email_delivery_setting_of_issue_reply
  end

  def test_get_new_with_disable_module_and_have_record
    @project.disable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)

    get :new, { project_id: 1 }
    assert_response :success
    assert_select 'div#email-addresses', false
    assert @project.email_delivery_setting_of_issue_reply
  end

  def test_get_new_with_enable_module_and_no_record
    @project.enable_module!(:send_issue_reply_email)

    get :new, { project_id: 1 }
    assert_response :success
    assert_select 'div#email-addresses', false
    assert_nil @project.email_delivery_setting_of_issue_reply
  end

  def test_get_new_with_disable_module_and_no_record
    @project.disable_module!(:send_issue_reply_email)

    get :new, { project_id: 1 }
    assert_response :success
    assert_select 'div#email-addresses', false
    assert_nil @project.email_delivery_setting_of_issue_reply
  end

  # issues/1/edit
  def test_get_edit_with_default_send_email_on_and_plain_text_on
    @project.enable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)
    @email_delivery_setting.update(default_send_email: '1', plain_text: true)

    issue = Issue.find(1)
    email = DummyMail.new(from: [ 'dummy-from@customer.co.jp' ],
      reply_to: nil, to: [ 'dummy-to@matsukei.co.jp' ],
      cc: [ 'dummy-cc-1@matsukei.co.jp', 'dummy-cc-2@matsukei.co.jp' ])
    EmailAddressOfIssueReply.create_by_received_mail(issue.id, email)

    get :edit, { id: issue.id }
    assert_response :success

    assert_select 'input[name=is_send_email][checked=checked]', count: 1
    assert_select 'div#email-addresses' do
      assert_select 'input[type=hidden][name=?]', 'issue[email_address_of_issue_reply_attributes][issue_id]'
      assert_select 'p#from_address', text: /dummy-from@matsukei.co.jp/
      assert_select 'p#reply_to_address', text: /dummy-reply-to@matsukei.co.jp/
      assert_select 'input[type=text][name=?][value=?]', 'issue[email_address_of_issue_reply_attributes][to_addresses]', 'dummy-from@customer.co.jp,dummy-to@matsukei.co.jp'
      assert_select 'input[type=text][name=?][value=?]', 'issue[email_address_of_issue_reply_attributes][cc_addresses]', 'dummy-cc-1@matsukei.co.jp,dummy-cc-2@matsukei.co.jp'
      assert_select 'input[type=text][name=?][value=?]', 'issue[email_address_of_issue_reply_attributes][subject]', '[Re: #1] Cannot print recipes'
    end
    assert_select 'div#email-header' do
      assert_select 'pre', text: /\*Header second line\*/
    end
    assert_select 'div#email-footer' do
      assert_select 'pre', text: /\*Footer second line\*/
    end
  end

  def test_get_edit_with_default_send_email_off_and_plain_text_off
    @project.enable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)
    @email_delivery_setting.update(default_send_email: '0', plain_text: false, reply_to_address: '')

    issue = Issue.find(1)
    email = DummyMail.new(from: [ 'dummy-from@customer.co.jp' ],
      reply_to: nil, to: [ 'dummy-to@matsukei.co.jp' ],
      cc: [ 'dummy-cc-1@matsukei.co.jp', 'dummy-cc-2@matsukei.co.jp' ])
    EmailAddressOfIssueReply.create_by_received_mail(issue.id, email)

    get :edit, { id: 1 }
    assert_response :success

    assert_select 'input[name=is_send_email][checked=checked]', count: 0
    assert_select 'div#email-addresses' do
      assert_select 'input[type=hidden][name=?]', 'issue[email_address_of_issue_reply_attributes][issue_id]'
      assert_select 'p#from_address', text: /dummy-from@matsukei.co.jp/
      assert_select 'p#reply_to_address', text: /dummy-reply-to@matsukei.co.jp/, count: 0
      assert_select 'input[type=text][name=?][value=?]', 'issue[email_address_of_issue_reply_attributes][to_addresses]', 'dummy-from@customer.co.jp,dummy-to@matsukei.co.jp'
      assert_select 'input[type=text][name=?][value=?]', 'issue[email_address_of_issue_reply_attributes][cc_addresses]', 'dummy-cc-1@matsukei.co.jp,dummy-cc-2@matsukei.co.jp'
      assert_select 'input[type=text][name=?][value=?]', 'issue[email_address_of_issue_reply_attributes][subject]', '[Re: #1] Cannot print recipes'
    end
    assert_select 'div#email-header' do
      assert_select 'strong', text: 'Header second line'
    end
    assert_select 'div#email-footer' do
      assert_select 'strong', text: 'Footer second line'
    end
  end

  def test_get_edit_with_disable_module_and_have_record
    @project.disable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)

    get :edit, { id: 1 }
    assert_response :success
    assert_select 'div#email-addresses', false
    assert @project.email_delivery_setting_of_issue_reply
  end

  def test_get_edit_with_enable_module_and_no_record
    @project.enable_module!(:send_issue_reply_email)

    get :edit, { id: 1 }
    assert_response :success
    assert_select 'div#email-addresses', false
    assert_nil @project.email_delivery_setting_of_issue_reply
  end

  def test_get_edit_with_disable_module_and_no_record
    @project.disable_module!(:send_issue_reply_email)

    get :edit, { id: 1 }
    assert_response :success
    assert_select 'div#email-addresses', false
    assert_nil @project.email_delivery_setting_of_issue_reply
  end

  def test_invalid_update_with_blank
    @project.enable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)

    with_settings notified_events: [] do
      assert_no_difference('Journal.count') do
        assert_no_difference('EmailAddressOfIssueReply.count') do
          put :update, {
            id: 1, issue: {
              notes: 'Fugafuga',
              email_address_of_issue_reply_attributes: {
                issue_id: '',
                to_addresses: '',
                cc_addresses: '',
                subject: ''
              }
            }, is_send_email: '1'
          }
          assert_response :success

          assert_include 'To cannot be blank', response.body
          assert_include 'Subject cannot be blank', response.body
        end
      end
    end

  end

  def test_invalid_update_with_format
    @project.enable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)

    with_settings notified_events: [] do
      assert_no_difference('Journal.count') do
        assert_no_difference('EmailAddressOfIssueReply.count') do
          put :update, {
            id: 1, issue: {
              notes: 'Fugafuga',
              email_address_of_issue_reply_attributes: {
                issue_id: '',
                to_addresses: 'hogehoge-invalid-address',
                cc_addresses: 'fugafuga-invalid-address',
                subject: 'Fugafuga'
              }
            }, is_send_email: '1'
          }
          assert_response :success

          assert_include 'To is invalid', response.body
          assert_include 'Cc is invalid', response.body
        end
      end
    end

  end

  # Do not send notification email
  def test_valid_edit_with_send_email_off
    @project.enable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)

    # Because the is_send_email is false.
    with_settings notified_events: [] do
      assert_difference('Journal.count') do
        assert_no_difference('EmailAddressOfIssueReply.count') do
          put :update, {
            id: 1, issue: {
              notes: 'Fugafuga'
            }, is_send_email: '0'
          }

          assert_redirected_to '/issues/1'
        end
      end
    end

    mail = last_email
    assert_nil mail

    # Because the notes is empty.
    with_settings notified_events: [] do
      assert_no_difference('Journal.count') do
        assert_difference('EmailAddressOfIssueReply.count') do
          put :update, {
            id: 1, issue: {
              notes: '',
              email_address_of_issue_reply_attributes: {
                issue_id: '',
                to_addresses: 'dummy-to1@matsukei.co.jp',
                cc_addresses: '',
                subject: '[Re: #1] Fugafuga'
              }
            }, is_send_email: '0'
          }

          assert_redirected_to '/issues/1'
        end
      end
    end

    mail = last_email
    assert_nil mail
  end

  def test_valid_edit_with_send_email_on
    set_tmp_attachments_directory

    @project.enable_module!(:send_issue_reply_email)
    @email_delivery_setting = generate_email_delivery_setting_of_same_redmine(@project)
    @email_delivery_setting.update(plain_text: false)

    # Do not send notification email
    # Because the notes is empty.
    with_settings notified_events: [] do
      assert_difference('Journal.count') do
        assert_difference('EmailAddressOfIssueReply.count') do
          put :update, {
            id: 1, issue: {
              notes: '',
              email_address_of_issue_reply_attributes: {
                issue_id: '',
                to_addresses: 'dummy-to2@matsukei.co.jp',
                cc_addresses: '',
                subject: '[Re: #1] Fugafuga'
              }
            }, is_send_email: '1',
            attachments: {
              '1' => {
                'file' => uploaded_test_file('testfile.txt', 'text/plain'),
                'description' => 'test1'
              }
            }
          }

          assert_redirected_to '/issues/1'
        end
      end
    end

    mail = last_email
    assert_nil mail

    # Send a notification email.
    with_settings notified_events: [] do
      assert_difference('Journal.count') do
        assert_no_difference('EmailAddressOfIssueReply.count') do
          put :update, {
            id: 1, issue: {
              notes: "Send a notification email!!\r\nYou can send it to an email address that is *not a Redmine user* .",
              email_address_of_issue_reply_attributes: {
                issue_id: '',
                to_addresses: 'dummy-to3@matsukei.co.jp',
                cc_addresses: 'dummy-cc1@matsukei.co.jp,dummy-cc2@matsukei.co.jp',
                subject: '[Re: #1] Hogehoge'
              }
            }, is_send_email: '1',
            attachments: {
              '1' => {
                'file' => uploaded_test_file("hg-export.diff", "text/plain"),
                'description' => 'test2'
              }
            }
          }

          assert_redirected_to '/issues/1'
        end
      end
    end

    mail = last_email
    assert mail

    assert_equal 1, mail.attachments.count
    assert mail.attachments['hg-export.diff']

    assert_equal [ 'dummy-from@matsukei.co.jp' ], mail.from.to_a
    assert_equal [ 'dummy-reply-to@matsukei.co.jp' ], mail.reply_to.to_a
    assert_equal [ 'dummy-to3@matsukei.co.jp' ], mail.to.to_a
    assert_equal [ 'dummy-cc1@matsukei.co.jp', 'dummy-cc2@matsukei.co.jp' ], mail.cc.to_a
    assert_equal [], mail.bcc.to_a
    assert_equal '[Re: #1] Hogehoge', mail.subject

    assert_equal 'ecookbook', mail.header['X-Redmine-Project'].to_s
    assert_equal '1', mail.header['X-Redmine-Issue-Id'].to_s

    assert_select_email do
      assert_select ".header" do
        assert_select "strong", text: "Header second line"
      end
      assert_select "p", text: /Send a notification email!!/
      assert_select ".footer" do
        assert_select "strong", text: "Footer second line"
      end
    end

  end

end
