require File.expand_path('../../test_helper', __FILE__)

class SendIssueReplyEmail::EmailDeliverySettingOfIssueRepliesControllerTest < ActionController::TestCase
  tests EmailDeliverySettingOfIssueRepliesController

  fixtures :users, :email_addresses, :user_preferences, :roles,
    :projects, :members, :member_roles, :issues, :issue_statuses,
    :trackers, :enumerations, :custom_fields, :auth_sources, :queries, :workflows,
    :versions, :journals, :journal_details, :projects_trackers,
    :enabled_modules, :boards, :messages, :attachments, :custom_values, :time_entries,
    :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
    :comments

  def setup
    ActionMailer::Base.deliveries.clear
    # User: jsmith
    @request.session[:user_id] = 2
    Setting.default_language = 'en'
    # Project: ecookbook
    Project.find(1).enable_module!(:send_issue_reply_email)
    # Role: Manager
    Role.find(1).add_permission!(:manage_email_delivery_setting)
  end

  def test_invalid_test_email
    project = Project.find(1)
    assert_nil project.email_delivery_setting_of_issue_reply

    post :test_email, { id: project.id }
    assert_redirected_to '/projects/ecookbook/settings/email_delivery_setting_of_issue_reply'

    assert_nil flash[:notice]
    assert flash[:error].match(/An error occurred while sending mail/)
  end

  def test_valid_test_email
    project = Project.find(1)
    email_delivery_setting = generate_email_delivery_setting_of_same_redmine(project)
    assert_not_nil project.email_delivery_setting_of_issue_reply

    post :test_email, { id: project.id }
    assert_redirected_to '/projects/ecookbook/settings/email_delivery_setting_of_issue_reply'

    assert_nil flash[:error]
    assert flash[:notice].match(/An email was sent to/)
  end

  def test_invalid_edit_with_blank
    assert_nil Project.find(1).email_delivery_setting_of_issue_reply
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      xhr :post, :edit, {
        id: 1,
        email_delivery_setting_of_issue_reply: {
          project_id: '',
          from_address: ''
        }
      }
    end

    assert_response :success
    assert_equal 'text/javascript', response.content_type

    assert_include 'Project cannot be blank', response.body
    assert_include 'From cannot be blank', response.body
    assert_not_include 'Send a test email', response.body
  end

  def test_invalid_edit_with_format
    assert_nil Project.find(1).email_delivery_setting_of_issue_reply
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      xhr :post, :edit, {
        id: 1,
        email_delivery_setting_of_issue_reply: {
          project_id: 1,
          from_address: 'hogehoge-invalid-address',
          reply_to_address: 'fugafuga-invalid-address'
        }
      }
    end

    assert_response :success
    assert_equal 'text/javascript', response.content_type
    assert_include 'From is invalid', response.body
    assert_include 'Reply-To is invalid', response.body
    assert_not_include 'Send a test email', response.body
  end

  def test_invalid_edit_with_no_xhr
    # get
    expected_values = expected_values_on_create_email_delivery_setting

    assert_nil Project.find(1).email_delivery_setting_of_issue_reply
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      get :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_response 404
    assert_nil Project.find(1).email_delivery_setting_of_issue_reply

    # put
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      put :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_response 404
    assert_nil Project.find(1).email_delivery_setting_of_issue_reply

    # post
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      post :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_response 404
    assert_nil Project.find(1).email_delivery_setting_of_issue_reply
  end

  def test_valid_edit
    # get
    expected_values = expected_values_on_create_email_delivery_setting

    assert_nil Project.find(1).email_delivery_setting_of_issue_reply
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      xhr :get, :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_response :success
    assert_nil Project.find(1).email_delivery_setting_of_issue_reply

    # put
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      xhr :put, :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_response :success
    assert_nil Project.find(1).email_delivery_setting_of_issue_reply

    # post: create
    assert_difference 'EmailDeliverySettingOfIssueReply.count' do
      xhr :post, :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_email_delivery_setting_edit_expected_values expected_values.merge(
      plain_text: true, use_settings_of_redmine: true, default_send_email: false),
      Project.find(1).email_delivery_setting_of_issue_reply

    # post: changed
    expected_values = expected_values_on_changed_update_email_delivery_setting
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      xhr :post, :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_email_delivery_setting_edit_expected_values expected_values.merge(
      plain_text: false, use_settings_of_redmine: false, default_send_email: true),
      Project.find(1).email_delivery_setting_of_issue_reply

    # post: blank
    expected_values = expected_values_on_blank_update_email_delivery_setting
    assert_no_difference 'EmailDeliverySettingOfIssueReply.count' do
      xhr :post, :edit, {
        id: 1, email_delivery_setting_of_issue_reply: expected_values
      }
    end
    assert_email_delivery_setting_edit_expected_values expected_values.merge(
      plain_text: nil, use_settings_of_redmine: nil, default_send_email: nil),
      Project.find(1).email_delivery_setting_of_issue_reply
  end

end
