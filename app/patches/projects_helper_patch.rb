require_dependency 'projects_helper'

module SendIssueReplyEmail
  module ProjectsHelperPatch
    unloadable

    extend ActiveSupport::Concern

    included do
      alias_method_chain :project_settings_tabs, :email_delivery_setting_of_issue_reply_tab
    end

    def project_settings_tabs_with_email_delivery_setting_of_issue_reply_tab
      tabs = project_settings_tabs_without_email_delivery_setting_of_issue_reply_tab

      if User.current.allowed_to?(:manage_email_delivery_setting, @project) &&
          @project.module_enabled?(:send_issue_reply_email)

        tabs << {
          name: 'email_delivery_setting_of_issue_reply',
          action: :manage_email_delivery_setting,
          partial: 'projects/settings/email_delivery_setting_of_issue_reply',
          label: :label_send_issue_reply_email
        }
      end

      tabs
    end

  end
end

SendIssueReplyEmail::ProjectsHelperPatch.tap do |mod|
  ProjectsHelper.send :include, mod unless ProjectsHelper.include?(mod)
end
