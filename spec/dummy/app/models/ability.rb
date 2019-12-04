# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, WasteCarriersEngine::Registration, account_email: user.email
    can :manage, WasteCarriersEngine::RenewingRegistration, account_email: user.email
    can :order_copy_cards, WasteCarriersEngine::Registration
  end
end
