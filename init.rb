AccountController.send(:include, RedmineLoginAttemptsLimit::AccountControllerPatch)

Redmine::Plugin.register :login_attempts_limit do
  name 'LoginAttemptsLimit'
  author 'midnightSuyama'
  description 'Login attempts limit plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/midnightSuyama/redmine_login_attempts_limit'
  settings default: { attempts_limit: 3, block_minutes: 60 }, partial: 'settings/login_attempts_limit_settings'
end
