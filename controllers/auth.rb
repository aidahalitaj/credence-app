# frozen_string_literal: true

require 'roda'

module Credence
  # Web controller for Credence API
  class App < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      @login_route = '/auth/login'
      @oauth_callback = '/auth/sso_callback'

      def gh_oauth_url(config)
        url = config.GH_OAUTH_URL
        client_id = config.GH_CLIENT_ID
        scope = config.GH_SCOPE

        "#{url}?client_id=#{client_id}&scope=#{scope}"
      end

      routing.is 'sso_callback' do
        # GET /auth/sso_callback
        routing.get do
          sso_account = AuthenticateGithubAccount
                        .new(App.config)
                        .call(routing.params['code'])

          current_user = User.new(sso_account['account'],
                                  sso_account['auth_token'])

          Session.new(SecureSession.new(session)).set_user(current_user)
          flash[:notice] = "Welcome #{current_user.username}!"
          routing.redirect '/projects'
        rescue StandardError => error
          puts error.inspect
          puts error.backtrace
          flash[:error] = 'Could not sign in using Github'
          routing.redirect @login_route
        end
      end

      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login, locals: {
            gh_oauth_url: gh_oauth_url(App.config)
          }
        end

        # POST /auth/login
        routing.post do
          credentials = Form::LoginCredentials.call(routing.params)

          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new(App.config).call(credentials)
          current_user = User.new(authenticated['account'],
                                  authenticated['auth_token'])

          Session.new(SecureSession.new(session)).set_user(current_user)
          flash[:notice] = "Welcome back #{current_user.username}!"
          routing.redirect '/'
        rescue StandardError
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
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            registration = Form::Registration.call(routing.params)

            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            VerifyRegistration.new(App.config).call(registration)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue StandardError
            flash[:error] = 'Please check username and email'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/[registration_token]
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
