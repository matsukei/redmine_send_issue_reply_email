require File.expand_path('../../test_helper', __FILE__)

class SendIssueReplyEmail::MailHandlerTest < ActiveSupport::TestCase

  fixtures :users, :email_addresses, :user_preferences, :roles,
    :projects, :members, :member_roles, :issues, :issue_statuses,
    :trackers, :enumerations, :custom_fields, :auth_sources, :queries, :workflows,
    :versions, :journals, :journal_details, :projects_trackers,
    :enabled_modules, :boards, :messages, :attachments, :custom_values, :time_entries,
    :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
    :comments

  FIXTURES_PATH = File.dirname(__FILE__) + '/../../../../test/fixtures/mail_handler'

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.notified_events = []
  end

  def test_create_issue
    assert_difference 'EmailAddressOfIssueReply.count' do
      issue = submit_email(
        'ticket_by_unknown_user.eml',
        issue: { project: 'ecookbook' },
        unknown_user: 'accept', no_permission_check: '1')

      assert issue.is_a?(Issue)
      assert_equal 'Ticket by unknown user', issue.subject

      issue_reply = issue.email_address_of_issue_reply
      assert issue_reply
      assert_equal [ 'john.doe@somenet.foo', 'redmine@somenet.foo' ], issue_reply.to
      assert_equal [], issue_reply.cc
      assert_equal '[Re: #' + issue.id.to_s + '] Ticket by unknown user', issue_reply.subject
    end

  end

  def test_update_issue
    assert_difference 'EmailAddressOfIssueReply.count' do
      journal = submit_email('ticket_reply.eml')

      assert journal.is_a?(Journal)
      assert_match /This is reply/, journal.notes

      issue = journal.issue
      assert_equal 'Add ingredients categories', issue.subject

      issue_reply = issue.email_address_of_issue_reply
      assert issue_reply
      assert_equal [ 'jsmith@somenet.foo', 'redmine@somenet.foo' ], issue_reply.to
      assert_equal [], issue_reply.cc
      assert_equal '[Re: #2] Add ingredients categories', issue_reply.subject
    end

  end

  private

    def submit_email(filename, options = {})
      raw = IO.read(File.join(FIXTURES_PATH, filename))
      yield raw if block_given?
      MailHandler.receive(raw, options)
    end

end
