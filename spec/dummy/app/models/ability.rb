# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, WasteCarriersEngine::Registration, account_email: user.email
    can :manage, WasteCarriersEngine::RenewingRegistration, account_email: user.email
    can :edit, WasteCarriersEngine::Registration
    can :order_copy_cards, WasteCarriersEngine::Registration
    can :cease, WasteCarriersEngine::Registration
    can :revoke, WasteCarriersEngine::Registration
  end
end
