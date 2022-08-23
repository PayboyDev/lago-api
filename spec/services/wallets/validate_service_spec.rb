# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wallets::ValidateService, type: :service do
  subject(:validate_service) { described_class.new(result, **args) }

  let(:result) { BaseService::Result.new }
  let(:membership) { create(:membership) }
  let(:organization) { membership.organization }
  let(:customer) { create(:customer, organization: organization) }
  let(:subscription) { create(:subscription, customer: customer) }
  let(:customer_id) { customer.id }
  let(:paid_credits) { '1.00' }
  let(:granted_credits) { '0.00' }
  let(:args) do
    {
      customer_id: customer_id,
      organization_id: organization.id,
      paid_credits: paid_credits,
      granted_credits: granted_credits,
    }
  end

  before { subscription }

  describe '.valid?' do
    it 'returns true' do
      expect(validate_service).to be_valid
    end

    context 'when customer does not exist' do
      let(:customer_id) { '123456' }

      it 'returns false and result has errors' do
        expect(validate_service).not_to be_valid
        expect(result.error_details[:customer]).to include('customer_not_found')
      end
    end

    context 'when customer has no active subscription' do
      before { subscription.mark_as_terminated! }

      it 'returns false and result has errors' do
        expect(validate_service).not_to be_valid
        expect(result.error_details[:customer]).to include('no_active_subscription')
      end
    end

    context 'when customer already has a wallet' do
      before { create(:wallet, customer: customer) }

      it 'returns false and result has errors' do
        expect(validate_service).not_to be_valid
        expect(result.error_details[:customer]).to include('wallet_already_exists')
      end
    end

    context 'with invalid paid_credits' do
      let(:paid_credits) { 'foobar' }

      it 'returns false and result has errors' do
        expect(validate_service).not_to be_valid
        expect(result.error_details[:paid_credits]).to include('invalid_paid_credits')
      end
    end

    context 'with invalid granted_credits' do
      let(:granted_credits) { 'foobar' }

      it 'returns false and result has errors' do
        expect(validate_service).not_to be_valid
        expect(result.error_details[:granted_credits]).to include('invalid_granted_credits')
      end
    end
  end
end
