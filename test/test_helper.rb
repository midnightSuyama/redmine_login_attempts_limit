# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

Dir[File.expand_path('../../lib/redmine_login_attempts_limit', __FILE__) << '/*.rb'].each do |file|
  require file
end

require File.expand_path('../../app/controllers/invalid_accounts_controller.rb', __FILE__)
