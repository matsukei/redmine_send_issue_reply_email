require File.expand_path('../../test_helper', __FILE__)

class SendIssueReplyEmail::ProjectsControllerTest < ActionController::TestCase
  tests ProjectsController

  fixtures :users, :email_addresses, :user_preferences, :roles,
    :projects, :members, :member_roles, :issues, :issue_statuses,
    :trackers, :enumerations, :custom_fields, :auth_sources, :queries, :workflows,
    :versions, :journals, :journal_details, :projects_trackers,
    :enabled_modules, :boards, :messages, :attachments, :custom_values, :time_entries,
    :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
    :comments

  def setup
    Setting.default_language = 'en'
  end

  def test_show_settings_with_issue_reply
    # User: jsmith
    @request.session[:user_id] = 2
    # Project member: yes, no
    project_ids = [ 1, 3 ]
    enabled_module_methods = [ :enable_module!, :disable_module! ]
    role_permission_methods = [ :add_permission!, :remove_permission! ]
    # Other tabs are displayed: yes, no
    response_codes = [ :success, :success, :success, :success, 403, 403, 403, 403 ]
    element_count = [ 1, 0, 0, 0, 0, 0, 0, 0 ]

    project_ids.each do |project_id|
      enabled_module_methods.each do |enabled_module_method|
        role_permission_methods.each do |role_permission_method|
          Project.find(project_id).public_send(enabled_module_method, :send_issue_reply_email)
          Role.find(1).public_send(role_permission_method, :manage_email_delivery_setting)

          get :settings, { id: project_id, tab: 'email_delivery_setting_of_issue_reply' }
          assert_response response_codes.shift
          assert_select('div.tabs > ul > li > a#tab-email_delivery_setting_of_issue_reply', count: element_count.shift)
        end
      end
    end
  end

  def test_issue_reply_email_setting
    # User: admin
    @request.session[:user_id] = 1
    Project.find(1).enable_module!(:send_issue_reply_email)

    get :settings, { id: 1, tab: 'email_delivery_setting_of_issue_reply' }
    assert_response :success
    assert_select 'form#email-delivery-setting' do
      assert_select 'input[type=hidden][name=?]',
        'email_delivery_setting_of_issue_reply[project_id]'

      assert_select 'input[name=?]:not([checked]):not([disabled])',
        'email_delivery_setting_of_issue_reply[default_send_email]'

      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[from_address]'
      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[reply_to_address]'

      assert_select 'textarea[name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[header]'
      assert_select 'textarea[name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[footer]'

      assert_select 'input[name=?]:not([checked]):not([disabled])',
        'email_delivery_setting_of_issue_reply[use_settings_of_redmine]'

      assert_select 'select[name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[delivery_method]'

      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[server_location]'
      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[server_arguments]'

      assert_select 'select[name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[enable_starttls_auto]'
      assert_select 'select[name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[openssl_verify_mode]'

      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[server_address]'
      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[server_port]'
      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[server_domain]'

      assert_select 'select[name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[authentication]'
      assert_select 'input[type=text][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[account]'
      assert_select 'input[type=password][name=?]:not([disabled])',
        'email_delivery_setting_of_issue_reply[account_password]'

      assert_select 'a', text: /Send a test email/, count: 0
    end

  end

end
