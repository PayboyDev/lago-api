# frozen_string_literal: true

module Webhooks
  module PaymentProviders
    class CreditNoteRefundFailureService < Webhooks::BaseService
      private

      alias credit_note object

      def current_organization
        @current_organization ||= credit_note.organization
      end

      def object_serializer
        ::V1::PaymentProviders::CreditNoteRefundErrorSerializer.new(
          credit_note,
          root_name: object_type,
          provider_error: options[:provider_error],
          provider_customer_id: options[:provider_customer_id],
        )
      end

      def webhook_type
        'credit_note.refund_failure'
      end

      def object_type
        'payment_provider_credit_note_refund_error'
      end
    end
  end
end
