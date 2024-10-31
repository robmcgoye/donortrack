module UsersHelper

  def get_user_id(user)
    if user.id.nil?
      -1
    else
      user.id
    end
  end
end
