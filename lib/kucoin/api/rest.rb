# frozen_string_literal: true
module Kucoin
  module Api
    class REST
      BASE_URL          = 'https://openapi-v2.kucoin.com'.freeze
      SANDBOX_BASE_URL  = 'https://openapi-sandbox.kucoin.com'.freeze
      API_KEY           = ENV['KUCOIN_API_KEY'].to_s
      API_SECRET        = ENV['KUCOIN_API_SECRET'].to_s
      API_PASSPHRASE    = ENV['KUCOIN_API_PASSPHRASE'].to_s

      attr_reader :api_key, :api_secret, :api_passphrase
      attr_reader :adapter

      def initialize api_key: API_KEY, api_secret: API_SECRET, api_passphrase: API_PASSPHRASE, adapter: Faraday.default_adapter, sandbox: false
        @api_key = api_key
        @api_secret = api_secret
        @api_passphrase = api_passphrase
        @adapter = adapter
        @sandbox = sandbox
      end
      def sandbox?; @sandbox == true end

      def base_url
        sandbox? ? SANDBOX_BASE_URL : BASE_URL
      end

      def account
        @account ||= Kucoin::Api::Endpoints::Account.new(self)
      end

      def currency
        @currency ||= Kucoin::Api::Endpoints::Currency.new(self)
      end

      def language
        @language ||= Kucoin::Api::Endpoints::Language.new(self)
      end

      def market
        @market ||= Kucoin::Api::Endpoints::Market.new(self)
      end

      def order
        @order ||= Kucoin::Api::Endpoints::Order.new(self)
      end

      def user
        @user ||= Kucoin::Api::Endpoints::User.new(self)
      end

      def open endpoint
        Connection.new(endpoint, url: base_url) do |conn|
          conn.request :json
          conn.response :json, content_type: 'application/json'
          conn.adapter adapter
        end
      end

      def auth endpoint
        Connection.new(endpoint, url: base_url) do |conn|
          conn.request :json
          conn.response :json, content_type: 'application/json'
          conn.use Kucoin::Api::Middleware::NonceRequest
          conn.use Kucoin::Api::Middleware::AuthRequest, api_key, api_secret, api_passphrase
          conn.adapter adapter
        end
      end
    end
  end
end
