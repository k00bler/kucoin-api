# frozen_string_literal: true
module Kucoin
  module Api
    module Endpoints
      class User
        class Accounts < User
          def create currency, type
            options = { currency: currency, type: type }
            assert_param_is_one_of options, :type, account_types
            auth.ku_request :post, :index, **options
          end

          def index options={}
            auth.ku_request :get, :index, **options
          end
          alias all index
          alias list index

          def inner_transfer currency, from, to, amount
            require "securerandom"
            client_oid = SecureRandom.uuid
            auth.ku_request :post, :inner_transfer, clientOid: client_oid, currency: currency, from: from, to: to, amount: amount
          end

          def show account_id
            auth.ku_request :get, :show, account_id: account_id
          end
          alias get show
          alias detail show

          def ledgers account_id, options={}
            auth.ku_request :get, :ledgers, account_id: account_id, **options
          end

          def holds account_id
            auth.ku_request :get, :holds, account_id: account_id
          end
        end
      end
    end
  end
end
