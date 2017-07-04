require File.expand_path('../../test_helper', __FILE__)

class EmailAddressOfIssueReplyTest < ActiveSupport::TestCase

  fixtures :users, :email_addresses, :user_preferences, :roles,
    :projects, :members, :member_roles, :issues, :issue_statuses,
    :trackers, :enumerations, :custom_fields, :auth_sources, :queries, :workflows,
    :versions, :journals, :journal_details, :projects_trackers,
    :enabled_modules, :boards, :messages, :attachments, :custom_values, :time_entries,
    :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
    :comments

  def setup
    EmailAddressOfIssueReply.destroy_all
  end

  def test_create_by_received_mail
    issue = Issue.find(1)
    email = DummyMail.new(from: [ 'dummy-from@matsukei.co.jp' ],
      reply_to: [ 'dummy-reply-to@matsukei.co.jp' ],
      to: [ 'dummy-to@matsukei.co.jp' ],
      cc: [ 'dummy-cc@matsukei.co.jp' ])

    assert_difference 'EmailAddressOfIssueReply.count' do
      assert_nil issue.email_address_of_issue_reply

      EmailAddressOfIssueReply.create_by_received_mail(issue.id, email)
      issue.reload

      issue_reply = issue.email_address_of_issue_reply
      assert issue_reply
      assert_equal [ 'dummy-reply-to@matsukei.co.jp' ], issue_reply.to
      assert_equal [ 'dummy-cc@matsukei.co.jp' ], issue_reply.cc
      assert_equal '[Re: #1] Cannot print recipes', issue_reply.subject
    end

    updated_at = Time.now
    email = DummyMail.new(from: [ 'dummy-from@matsukei.co.jp' ])
    assert_no_difference 'EmailAddressOfIssueReply.count' do
      assert issue.email_address_of_issue_reply

      EmailAddressOfIssueReply.create_by_received_mail(issue.id, email)
      issue.reload

      issue_reply = issue.email_address_of_issue_reply
      assert issue_reply
      assert issue_reply.updated_at < updated_at
    end
  end

end
