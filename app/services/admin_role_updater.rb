class AdminRoleUpdater
  attr_reader :message, :message_type
  def initialize(user, admin)
    @user = user
    @admin = admin
  end

  def update
    if @admin
      add_admin_role
    else
      remove_admin_role
    end
    self
  end

  private

  def add_admin_role
    if @user.add_admin_role
      set_success
    else
      set_error("ERROR adding admin role.")
    end
  end

  def remove_admin_role
    if @user.remove_admin_role
      set_success
    else
      set_error("ERROR removing admin role.")
    end
  end

  def set_success
    @message = "Admin status updated successfully."
    @message_type = "notice"
  end

  def set_error(message)
    @message_type = "alert"
    @message = @user.errors.any? ? @user.errors.full_messages.first : message
  end
end
