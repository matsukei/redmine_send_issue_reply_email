require File.expand_path('../../test_helper', __FILE__)

class SendIssueReplyEmail::MailHandlerTest < ActiveSupport::TestCase

  fixtures :users, :email_addresses, :user_preferences, :roles,
    :projects, :members, :member_roles, :issues, :issue_statuses,
    :trackers, :enumerations, :custom_fields, :auth_sources, :queries, :workflows,
    :versions, :journals, :journal_details, :projects_trackers,
    :enabled_modules, :boards, :messages, :attachments, :custom_values, :time_entries,
    :wikis, :wiki_pages, :wiki_contents, :wiki_content_versions,
    :comments

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.notified_events = []
  end

  def test_create_issue
    assert_difference 'EmailAddressOfIssueReply.count' do
      issue = receive_issue_create_email(issue: { project: 'ecookbook' },
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
      journal = receive_issue_reply_email

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

    def submit_email(raw, options)
      MailHandler.receive(raw, options)
    end

    def receive_issue_create_email(options = {})
      raw = <<-'EOS'
Return-Path: <john.doe@somenet.foo>
Message-ID: <000501c8d452$a95cd7e0$0a00a8c0@osiris>
From: "John Doe" <john.doe@somenet.foo>
To: <redmine@somenet.foo>
Subject: Ticket by unknown user
Date: Sun, 22 Jun 2008 12:28:07 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit

This is a ticket submitted by an unknown user.
        EOS

      submit_email(raw, options)
    end

    def receive_issue_reply_email(options = {})
      raw = <<-'EOS'
Return-Path: <jsmith@somenet.foo>
Message-ID: <006a01c8d3bd$ad9baec0$0a00a8c0@osiris>
From: "John Smith" <jsmith@somenet.foo>
To: <redmine@somenet.foo>
References: <485d0ad366c88_d7014663a025f@osiris.tmail>
Subject: Re: [Cookbook - Feature #2] (New) Add ingredients categories
Date: Sat, 21 Jun 2008 18:41:39 +0200
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0067_01C8D3CE.711F9CC0"

This is a multi-part message in MIME format.

------=_NextPart_000_0067_01C8D3CE.711F9CC0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable

This is reply
        EOS

      submit_email(raw, options)
    end

end
