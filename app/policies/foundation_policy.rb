class FoundationPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def crud_actions?
    @user.has_any_role? :admin
    # authorized_roles?
  end

  # def show?
  #   authorized_roles?
  # end

  # def edit?
  #   authorized_roles?
  # end

  # def new?
  #   authorized_roles?
  # end

  # private

  # def authorized_roles?
  #   @user.has_any_role? :admin, :tech
  # end
end
