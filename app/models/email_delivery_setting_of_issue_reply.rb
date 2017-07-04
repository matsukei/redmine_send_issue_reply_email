class EmailDeliverySettingOfIssueReply < ActiveRecord::Base
  unloadable

  include Redmine::Ciphering

  has_one :project

  # See: http://www.redmine.org/projects/redmine/wiki/EmailConfiguration
  # See: http://www.rubydoc.info/github/mikel/mail/Mail/SMTP
  AUTHENTICATIONS = [ '', 'plain', 'login', 'cram_md5' ]
  DELIVERY_METHODS = [ 'smtp', 'sendmail', 'async_smtp', 'async_sendmail' ]
  OPENSSL_VERIFY_MODES = [ '', 'none', 'peer' ]

  validates :project_id, :from_address, presence: true
  validates :from_address, :reply_to_address, format: {
    with: EmailAddressOfIssueReply::VALIDATE_EMAIL_REGEXP
  }, allow_blank: true

  def plain_text_mail?
    self.plain_text?
  end

  def account_password
    read_ciphered_attribute(:account_password)
  end

  def account_password=(arg)
    write_ciphered_attribute(:account_password, arg)
  end

  def wrap_headers(headers = {})
    headers[:from] = self.from_address
    headers[:reply_to] = self.reply_to_address
    headers[:plain_text] = self.plain_text_mail?

    unless self.use_settings_of_redmine?
      wrap_options = self.public_send(self.delivery_method.split('_').last + '_settings')
      # See: https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/base.rb#L825
      # See: https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/delivery_methods.rb#L54
      headers[:delivery_method] = self.delivery_method.to_sym
      headers[:delivery_method_options] = wrap_options
    end

    headers.merge! 'From' => self.from_address, 'Sender' => self.from_address,
      'List-Id' => "<#{self.from_address.to_s.gsub('@', '.')}>",
      'X-Redmine-Host' => '', 'X-Redmine-Site' => ''

    return headers
  end

  def base_settings
    settings = {}

    settings[:enable_starttls_auto] = self.enable_starttls_auto == '1' if self.enable_starttls_auto.present?
    settings[:openssl_verify_mode] = self.openssl_verify_mode if self.openssl_verify_mode.present?

    if self.authentication.present?
      settings[:authentication] = self.authentication.to_sym
      settings[:user_name] = self.account
      settings[:password] = self.account_password
    end

    return settings
  end

  def smtp_settings
    settings = self.base_settings

    settings[:address] = self.server_address
    settings[:port] = self.server_port
    settings[:domain] = self.server_domain

    return settings
  end

  def sendmail_settings
    settings = self.base_settings

    settings[:location] = self.server_location
    settings[:arguments] = self.server_arguments

    return settings
  end

end
