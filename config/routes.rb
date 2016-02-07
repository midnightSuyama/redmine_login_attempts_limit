# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'login_attempts_limit/clear', to: 'invalid_accounts#clear'
