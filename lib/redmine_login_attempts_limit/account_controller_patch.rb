module RedmineLoginAttemptsLimit
  module AccountControllerPatch
    def self.included(base)
      base.class_eval do
        alias_method_chain :password_authentication, :login_attempts_limit
        alias_method_chain :invalid_credentials, :login_attempts_limit
        alias_method_chain :successful_authentication, :login_attempts_limit
        alias_method_chain :lost_password, :login_attempts_limit
      end
    end

    def password_authentication_with_login_attempts_limit
      InvalidAccounts.clean_expired
      if InvalidAccounts.blocked? params[:username]
        flash.now[:error] = l('errors.blocked')
      else
        password_authentication_without_login_attempts_limit
      end
    end

    def invalid_credentials_with_login_attempts_limit
      InvalidAccounts.update(params[:username])
      if Setting.plugin_redmine_login_attempts_limit[:blocked_notification]
        if InvalidAccounts.blocked? params[:username]
          user = User.find_by(login: params[:username])
          Mailer.account_blocked(user).deliver unless user.nil?
        end
      end
      invalid_credentials_without_login_attempts_limit
      flash.now[:error] = l('errors.blocked') if InvalidAccounts.blocked? params[:username]
    end

    def successful_authentication_with_login_attempts_limit(user)
      InvalidAccounts.clear(user.login)
      successful_authentication_without_login_attempts_limit(user)
    end

    def lost_password_with_login_attempts_limit
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
      lost_password_without_login_attempts_limit
    end
  end
end
