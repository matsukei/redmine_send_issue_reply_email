module SendIssueReplyEmail
  class IssueViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_edit_notes_bottom, partial: 'email_form'
  end
end
