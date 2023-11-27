# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, WasteCarriersEngine::RenewingRegistration
    can :edit, WasteCarriersEngine::Registration
    can :order_copy_cards, WasteCarriersEngine::Registration
    can :cease, WasteCarriersEngine::Registration
    can :revoke, WasteCarriersEngine::Registration
  end
end
