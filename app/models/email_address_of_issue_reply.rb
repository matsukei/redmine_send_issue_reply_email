class EmailAddressOfIssueReply < ActiveRecord::Base
  unloadable

  has_one :issue

  VALIDATE_EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  validates :to_addresses, :subject, presence: true
  validates_each :to_addresses, :cc_addresses, allow_blank: true do |record, attr, value|
    record.errors.add(attr, :invalid) if value.split(',').reject do |address|
      address =~ VALIDATE_EMAIL_REGEXP
    end.present?
  end

  def to
    self.to_addresses.split(',')
  end

  def cc
    self.cc_addresses.split(',')
  end

  class << self

    def create_by_received_mail(issue_id, email)
      issue = Issue.find(issue_id)
      return if issue.email_address_of_issue_reply.present?

      # to: receive reply_to or from + to
      receive_reply_to = email.reply_to.to_a
      to = receive_reply_to.present? ? receive_reply_to : email.from.to_a + email.to.to_a
      # cc: receive cc
      cc = email.cc.to_a
      # subject: [Re: #XX] subject
      subject = '[Re: #' + issue_id.to_s + '] ' + issue.subject

      record = self.new(issue_id: issue_id,
        to_addresses: to.uniq.join(','),
        cc_addresses: cc.uniq.join(','),
        subject: subject)

      record.save(validate: false)
    end
  end

end
