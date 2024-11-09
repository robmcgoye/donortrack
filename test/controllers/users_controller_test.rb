# test/controllers/users_controller_test.rb
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # Setup some users for the tests
  def setup
    @user = users(:one)  # Assuming you have fixtures for users, or you can create them manually
    @admin_user = users(:admin)  # Admin user for permission tests
  end
  setup do
    @user = users(:one)
    session[:user_id] = @user.id
  end

  # test "should get index with turbo stream" do
  #   # Simulate a turbo stream request
  #   get users_url, headers: { "Accept" => "text/vnd.turbo-stream.html" }
  #   assert_response :success
  #   assert_select "turbo-stream[action='replace'][target='main_content']", count: 1
  # end

  # test "should get index with error for non-Turbo requests" do
  #   get users_url
  #   assert_response :success
  #   assert_template "errors/10"
  # end

  # test "should get new" do
  #   get new_user_url
  #   assert_response :success
  #   assert_select "form[action='#{users_path}']"
  # end

  # test "should create user with valid params" do
  #   assert_difference("User.count", 1) do
  #     post users_url, params: { user: { email: "new_user@example.com", password: "password", password_confirmation: "password" } }
  #   end
  #   assert_redirected_to user_path(User.last)
  # end

  # test "should not create user with invalid params" do
  #   post users_url, params: { user: { email: "", password: "", password_confirmation: "" } }
  #   assert_template :new
  #   assert_select "div#error_explanation"
  # end

  # test "should get edit" do
  #   get edit_user_url(@user)
  #   assert_response :success
  #   assert_select "form[action='#{user_path(@user)}']"
  # end

  # test "should update user with valid params" do
  #   patch user_url(@user), params: { user: { email: "updated_user@example.com" } }
  #   assert_redirected_to user_path(@user)
  #   @user.reload
  #   assert_equal "updated_user@example.com", @user.email
  # end

  # test "should not update user with invalid params" do
  #   patch user_url(@user), params: { user: { email: "" } }
  #   assert_template :edit
  #   assert_select "div#error_explanation"
  # end

  # test "should destroy user" do
  #   assert_difference("User.count", -1) do
  #     delete user_url(@user)
  #   end
  #   assert_redirected_to users_path
  # end

  # test "should not destroy current user" do
  #   sign_in @admin_user  # Assuming you use Devise for authentication
  #   delete user_url(@admin_user)
  #   assert_redirected_to users_path
  #   assert_not_nil flash[:alert]
  # end
end
