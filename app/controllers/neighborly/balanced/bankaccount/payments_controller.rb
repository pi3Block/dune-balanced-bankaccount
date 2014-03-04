module Neighborly::Balanced::Bankaccount
  class PaymentsController < AccountsController
    def create
      attach_bank_to_customer
      update_customer

      contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      redirect_to main_app.project_contribution_path(
        contribution.project.permalink,
        contribution.id
      )
    end

    private

    def attach_bank_to_customer
      bank_account = resource_params.fetch(:use_bank)
      unless customer.bank_accounts.any? { |c| c.id.eql? bank_account }
        customer.add_bank_account(resource_params.fetch(:use_bank))
      end
    end

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :use_bank,
                    :pay_fee,
                    user: {})
    end

    def prepare_new_view
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @bank_account            = customer.bank_accounts.try(:last)
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end
  end
end
