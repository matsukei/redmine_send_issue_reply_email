require_dependency 'issue'

module SendIssueReplyEmail
  module IssuePatch
    extend ActiveSupport::Concern
    unloadable

    included do
      unloadable

      has_one :email_address_of_issue_reply, dependent: :destroy
      accepts_nested_attributes_for :email_address_of_issue_reply

      safe_attributes 'email_address_of_issue_reply_attributes'
    end

  end
end

SendIssueReplyEmail::IssuePatch.tap do |mod|
  Issue.send :include, mod unless Issue.include?(mod)
end
