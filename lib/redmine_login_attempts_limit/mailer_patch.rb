module RedmineLoginAttemptsLimit
  module MailerPatch
    def account_blocked(user)
      @user = user
      admins = User.active.where(admin: true)
      mail to: @user.mail, bcc: admins.map(&:mail), subject: l('mailer.account_blocked_subject')
    end
  end
end
