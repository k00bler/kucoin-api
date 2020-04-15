# frozen_string_literal: true

Dir[File.expand_path('endpoints/*.rb', File.dirname(__FILE__))].each {|file| require file }
Dir[File.expand_path('endpoints/*/*.rb', File.dirname(__FILE__))].each {|file| require file }

module Kucoin
  module Api
    ENDPOINTS = {
      user:  {
        accounts: {
          index:            '/api/v1/accounts',
          inner_transfer:   '/api/v2/accounts/inner-transfer',
          # member
          show:             '/api/v1/accounts/:account_id',
          ledgers:          '/api/v1/accounts/:account_id/ledgers',
          holds:            '/api/v1/accounts/:account_id/holds',
        },
        deposits: {
          create:           '/api/v1/deposit-addresses',
          index:            '/api/v1/deposits',
          # member
          show:             '/api/v1/deposit-addresses?currency=:currency',
        },
        withdrawals: {
          index:            '/api/v1/withdrawals',
          quotas:           '/api/v1/withdrawals/quotas',
          # member
          delete:           '/api/v1/withdrawals/:withdrawal_id',
        }
      },
      trade:  {
        orders: {
          index:              '/api/v1/orders',
          recent:             '/api/v1/limit/orders',
          # member
          show:               '/api/v1/orders/:order_id',
        },
        fills: {
          index:              '/api/v1/fills',
          recent:             '/api/v1/limit/fills',
        }
      },
      markets: {
        index:                '/api/v1/markets',
        # member
        stats:                '/api/v1/market/stats?symbol=:symbol',
        symbols: {
          index:              '/api/v1/symbols',
        },
        tickers: {
          # member
          index:              '/api/v1/market/allTickers',
          inside:             '/api/v1/market/orderbook/level1?symbol=:symbol',
        },
        order_book: {
          part_aggregated:    '/api/v1/market/orderbook/level2_:depth?symbol=:symbol',
          full_aggregated:    '/api/v2/market/orderbook/level2?symbol=:symbol',
          full_atomic:        '/api/v1/market/orderbook/level3?symbol=:symbol',
        },
        histories: {
          trade:              '/api/v1/market/histories?symbol=:symbol',
          klines:             '/api/v1/market/candles?symbol=:symbol'
        },
        currencies: {
          index:              '/api/v1/currencies',
          fiat:               '/api/v1/prices',
          # member
          show:               '/api/v1/currencies/:currency',
        }
      },
      other: {
        timestamp:            '/api/v1/timestamp'
      },

      websocket: {
        public:                '/api/v1/bullet-public',
        private:               '/api/v1/bullet-private'
      }
    }

    module Endpoints
      def self.get_klass name, parent=nil
        Object.const_get("#{parent || 'Kucoin::Api::Endpoints'}::#{name.to_s.split('_').map(&:capitalize).join}")
      end

      def self.endpoint_method client_klass, name, result, parent_var = nil
        child_endpoint_klass = Endpoints.get_klass(name, (parent_var && parent_var.class))

        if parent_var
          parent_var.define_singleton_method name do
            endpoint_var = "@#{name}"
            var = instance_variable_get(endpoint_var) || instance_variable_set(endpoint_var, child_endpoint_klass.new(parent_var.client))
            client_klass.generate_endpoint_methods result: result, parent_var: var
            var
          end
        else
          client_klass.class_exec do
            define_method name do
              endpoint_var = "@#{name}"
              var = instance_variable_get(endpoint_var) || instance_variable_set(endpoint_var, child_endpoint_klass.new(self))
              client_klass.generate_endpoint_methods result: result, parent_var: var
              var
            end
          end
        end
      end

      def generate_endpoint_methods result: ENDPOINTS, parent_var: nil
        result.each do |endpoint_name, _result|
          if _result.is_a?(Hash)
            Kucoin::Api::Endpoints.endpoint_method(self, endpoint_name, _result, parent_var)
          end
        end
      end
    end
  end
end
