class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, WasteCarriersEngine::Registration, account_email: user.email
    can :manage, WasteCarriersEngine::TransientRegistration, account_email: user.email
  end
end
