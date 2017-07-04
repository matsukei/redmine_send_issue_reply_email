require 'mailer'

class IssueReplyMailer < Mailer
  layout 'issue_reply_mailer'

  after_action :apply_email_delivery_setting

  def mail(headers)
    plain_text_mail = headers.delete(:plain_text)

    @origin_to = headers[:to]
    @origin_cc = headers[:cc]

    super(headers) do |format|
      if plain_text_mail
        format.text
      else
        format.html
      end
    end
  end

  def notification(issue, journal)
    redmine_headers 'Project' => issue.project.identifier, 'Issue-Id' => issue.id
    message_id journal
    references issue

    @journal = journal
    @email_delivery_setting = issue.project.email_delivery_setting_of_issue_reply

    journal.details.where(property: 'attachment').each do |journal_detail|
      attachment = issue.attachments.where(id: journal_detail.prop_key).first
      attachments[attachment.filename] = File.read(attachment.diskfile) if attachment.present?
    end

    email_addresses = issue.email_address_of_issue_reply
    mail @email_delivery_setting.wrap_headers(
      to: email_addresses.to,
      cc: email_addresses.cc,
      subject: email_addresses.subject)
  end

  def test_email(user, project)
    @email_delivery_setting = project.email_delivery_setting_of_issue_reply
    set_language_if_valid(user.language)

    mail @email_delivery_setting.wrap_headers(
      to: user.mail, subject: 'Redmine issue reply test')
  end

  private

    def apply_email_delivery_setting
      headers[:to] = @origin_to
      headers[:cc] = @origin_cc
      headers[:bcc] = nil
    end

end
