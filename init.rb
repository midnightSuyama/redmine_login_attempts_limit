Mailer.send(:include, RedmineLoginAttemptsLimit::MailerPatch)
AccountController.send(:include, RedmineLoginAttemptsLimit::AccountControllerPatch)

Redmine::Plugin.register :redmine_login_attempts_limit do
  name 'LoginAttemptsLimit'
  author 'midnightSuyama'
  description 'Login attempts limit plugin for Redmine'
  version '0.1.1'
  url 'https://github.com/midnightSuyama/redmine_login_attempts_limit'
  settings(default: { attempts_limit: 3, block_minutes: 60, blocked_notification: true }, partial: 'settings/redmine_login_attempts_limit_settings')
end
