require_dependency 'project'

module SendIssueReplyEmail
  module ProjectPatch
    extend ActiveSupport::Concern
    unloadable

    included do
      unloadable

      has_one :email_delivery_setting_of_issue_reply, dependent: :destroy
    end

  end
end

SendIssueReplyEmail::ProjectPatch.tap do |mod|
  Project.send :include, mod unless Project.include?(mod)
end
