class EmailDeliverySettingOfIssueRepliesController < ApplicationController
  unloadable

  menu_item :settings
  before_action :find_project, :authorize

  def edit
    @email_delivery_setting = EmailDeliverySettingOfIssueReply.find_or_initialize_by(project_id: @project.id)
    @email_delivery_setting.update(permit_params) if request.xhr? && request.post?
  end

  def test_email
    raise_delivery_errors = ActionMailer::Base.raise_delivery_errors

    ActionMailer::Base.raise_delivery_errors = true
    begin
      @test = IssueReplyMailer.test_email(User.current, @project).deliver
      flash[:notice] = l(:notice_email_sent, ERB::Util.h(User.current.mail))
    rescue Exception => e
      flash[:error] = l(:notice_email_error, ERB::Util.h(Redmine::CodesetUtil.replace_invalid_utf8(e.message.dup)))
    end
    ActionMailer::Base.raise_delivery_errors = raise_delivery_errors

    redirect_to controller: :projects, action: :settings,
      id: @project.identifier, tab: :email_delivery_setting_of_issue_reply
  end

  private

    def permit_params
      params.require(:email_delivery_setting_of_issue_reply).permit(
        :project_id, :from_address, :reply_to_address,
        :plain_text, :header, :footer, :use_settings_of_redmine,
        :delivery_method, :server_location, :server_arguments,
        :enable_starttls_auto, :openssl_verify_mode,
        :server_address, :server_port, :server_domain,
        :authentication, :account, :account_password,
        :default_send_email)
    end

end
