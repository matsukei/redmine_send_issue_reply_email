require 'pathname'

module SendIssueReplyEmail
  def self.root
    @root ||= Pathname.new File.expand_path('..', File.dirname(__FILE__))
  end
end

Rails.configuration.to_prepare do
  # Load patches for Redmine
  Dir[SendIssueReplyEmail.root.join('app/patches/**/*_patch.rb')].each {|f| require_dependency f }
end

# Load hooks
Dir[SendIssueReplyEmail.root.join('app/hooks/*_hook.rb')].each {|f| require_dependency f }
