module RedmineLoginAttemptsLimit
  module AccountControllerPatch
    def password_authentication
      InvalidAccounts.clean_expired
      if InvalidAccounts.blocked? params[:username]
        flash.now[:error] = l('errors.blocked')
      else
        super
      end
    end

    def invalid_credentials
      InvalidAccounts.update(params[:username])
      if Setting.plugin_redmine_login_attempts_limit[:blocked_notification]
        if InvalidAccounts.blocked? params[:username]
          user = User.find_by(login: params[:username])
          Mailer.account_blocked(user).deliver unless user.nil?
        end
      end
      super
      flash.now[:error] = l('errors.blocked') if InvalidAccounts.blocked? params[:username]
    end

    def successful_authentication(user)
      InvalidAccounts.clear(user.login)
      super
    end

    def lost_password
      if Setting.lost_password? && request.post?
        token = Token.find_token("recovery", params[:token].to_s)
        if token && (!token.expired?)
          user = token.user
          if user && user.active?
            user.password, user.password_confirmation = params[:new_password], params[:new_password_confirmation]
            InvalidAccounts.clear(user.login) if user.valid?
          end
        end
      end
      super
    end
  end
end

RedmineLoginAttemptsLimit::AccountControllerPatch.tap do |mod|
  AccountController.send :prepend, mod unless AccountController.include?(mod)
end
