class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, TransientRegistration, account_email: user.email
  end
end
