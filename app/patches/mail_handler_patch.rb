require_dependency 'mail_handler'

module SendIssueReplyEmail
  module MailHandlerPatch
    extend ActiveSupport::Concern
    unloadable

    included do
      unloadable

      private

        def receive_issue_with_record_email_addresses
          issue = receive_issue_without_record_email_addresses
          EmailAddressOfIssueReply.create_by_received_mail(issue.id, email)

          return issue
        end

        def receive_issue_reply_with_record_email_addresses(issue_id, from_journal = nil)
          journal = receive_issue_reply_without_record_email_addresses(issue_id, from_journal)
          EmailAddressOfIssueReply.create_by_received_mail(issue_id, email)

          return journal
        end

        alias_method_chain :receive_issue, :record_email_addresses
        alias_method_chain :receive_issue_reply, :record_email_addresses
    end

  end
end

SendIssueReplyEmail::MailHandlerPatch.tap do |mod|
  MailHandler.send :include, mod unless MailHandler.include?(mod)
end
