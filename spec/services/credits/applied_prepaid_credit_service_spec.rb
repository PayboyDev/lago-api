# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Credits::AppliedPrepaidCreditService do
  subject(:credit_service) { described_class.new(invoice: invoice, wallet: wallet) }

  let(:invoice) do
    create(
      :invoice,
      customer: customer,
      amount_cents: amount_cents,
      amount_currency: 'EUR',
    )
  end
  let(:amount_cents) { 100 }
  let(:wallet) { create(:wallet, customer: customer, balance: '10.00', credits_balance: '10.00') }
  let(:customer) { create(:customer) }
  let(:subscription) { create(:subscription, customer: customer) }

  before { subscription }

  describe 'create' do
    it 'creates a prepaid credit' do
      result = credit_service.create

      expect(result).to be_success

      expect(result.prepaid_credit.amount_cents).to eq(100)
      expect(result.prepaid_credit.amount_currency).to eq('EUR')
      expect(result.prepaid_credit.invoice).to eq(invoice)
    end

    it 'creates wallet transaction' do
      result = credit_service.create

      expect(result).to be_success
      expect(result.prepaid_credit.wallet_transaction).to be_present
      expect(result.prepaid_credit.wallet_transaction.amount).to eq(1.0)
    end

    it 'updates wallet balance' do
      result = credit_service.create
      wallet = result.prepaid_credit.wallet_transaction.wallet

      expect(wallet.balance).to eq('9.0')
      expect(wallet.credits_balance).to eq('9.0')
    end

    context 'when wallet credits are less than invoice amount' do
      let(:amount_cents) { 1500 }

      it 'creates a prepaid credit' do
        result = credit_service.create

        expect(result).to be_success

        expect(result.prepaid_credit.amount_cents).to eq(1000)
        expect(result.prepaid_credit.amount_currency).to eq('EUR')
        expect(result.prepaid_credit.invoice).to eq(invoice)
      end

      it 'creates wallet transaction' do
        result = credit_service.create

        expect(result).to be_success
        expect(result.prepaid_credit.wallet_transaction).to be_present
        expect(result.prepaid_credit.wallet_transaction.amount).to eq(10.0)
      end

      it 'updates wallet balance' do
        result = credit_service.create
        wallet = result.prepaid_credit.wallet_transaction.wallet

        expect(wallet.balance).to eq('0.0')
        expect(wallet.credits_balance).to eq('0.0')
      end
    end
  end
end