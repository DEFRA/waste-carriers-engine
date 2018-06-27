class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Registration, account_email: user.email
    can :manage, TransientRegistration, account_email: user.email
  end
end
