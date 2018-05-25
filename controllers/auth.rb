# frozen_string_literal: true

require 'roda'

module Credence
  # Web controller for Credence API
  class App < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          authenticated = AuthenticateAccount.new(App.config).call(
            JsonRequestBody.symbolize(routing.params)
          )

          current_user = User.new(authenticated['account'],
                                  authenticated['auth_token'])

          Session.new(SecureSession.new(session)).set_user(current_user)
          flash[:notice] = "Welcome back #{current_user.username}!"
          routing.redirect '/'
        rescue StandardError => error
          puts "ERROR: #{error.inspect}"
          puts error.backtrace
          flash[:error] = 'Username and password did not match our records'
          routing.redirect @login_route
        end
      end

      routing.is 'logout' do
        routing.get do
          Session.new(SecureSession.new(session)).delete
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          routing.get do
            view :register
          end

          routing.post do
            account_data = JsonRequestBody.symbolize(routing.params)
            VerifyRegistration.new(App.config).call(account_data)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue StandardError => error
            puts "ERROR CREATING ACCOUNT: #{error.inspect}"
            puts error.backtrace
            flash[:error] = 'Account details are not valid: please check username and email'
            routing.redirect @register_route
          end
        end

        routing.get(String) do |registration_token|
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          new_account = SecureMessage.decrypt(registration_token)
          view :register_confirm,
               locals: { new_account: new_account,
                         registration_token: registration_token }
        end
      end
    end
  end
end
