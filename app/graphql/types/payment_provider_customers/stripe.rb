# frozen_string_literal: true

module Types
  module PaymentProviderCustomers
    class Stripe < Types::BaseObject
      graphql_name 'StripeCustomer'

      field :id, ID, null: false
      field :provider_customer_id, ID, null: true
      field :sync_with_provider, Boolean, null: true
    end
  end
end
