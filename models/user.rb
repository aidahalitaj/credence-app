# frozen_string_literal: true

module Credence
  # Behaviors of the currently logged in account
  class User
    def initialize(account, auth_token = nil)
      @account = account
      @auth_token = auth_token
    end

    attr_reader :account, :auth_token

    def username
      @account ? @account['username'] : nil
    end

    def email
      @account ? @account['email'] : nil
    end

    def logged_out?
      @auth_token.nil?
    end

    def logged_in?
      not logged_out?
    end
  end
end
