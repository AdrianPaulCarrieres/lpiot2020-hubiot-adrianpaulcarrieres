defmodule HubiotWeb.UserSettingsControllerTest do
  use HubiotWeb.ConnCase, async: true

  alias Hubiot.Accounts
  import Hubiot.AccountsFixtures

  setup :register_and_log_in_user

  describe "GET /users/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.user_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.user_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "PUT /users/settings (change password form)" do
    test "updates the user password and resets tokens", %{conn: conn, user: user} do
      new_password_conn =
        put(conn, Routes.user_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_user_password(),
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.user_settings_path(conn, :edit)
      assert get_session(new_password_conn, :user_token) != get_session(conn, :user_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Accounts.get_user_by_name_and_password(user.name, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.user_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :user_token) == get_session(conn, :user_token)
    end
  end

  describe "PUT /users/settings (change name form)" do
    @tag :capture_log
    test "updates the user name", %{conn: conn, user: user} do
      conn =
        put(conn, Routes.user_settings_path(conn, :update), %{
          "action" => "update_name",
          "current_password" => valid_user_password(),
          "user" => %{"name" => unique_user_name()}
        })

      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your name"
      assert Accounts.get_user_by_name(user.name)
    end

    test "does not update name on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.user_settings_path(conn, :update), %{
          "action" => "update_name",
          "current_password" => "invalid",
          "user" => %{"name" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /users/settings/confirm_name/:token" do
    setup %{user: user} do
      name = unique_user_name()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_name_instructions(%{user | name: name}, user.name, url)
        end)

      %{token: token, name: name}
    end

    test "updates the user name once", %{conn: conn, user: user, token: token, name: name} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_name, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "name changed successfully"
      refute Accounts.get_user_by_name(user.name)
      assert Accounts.get_user_by_name(name)

      conn = get(conn, Routes.user_settings_path(conn, :confirm_name, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "name change link is invalid or it has expired"
    end

    test "does not update name with invalid token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_name, "oops"))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "name change link is invalid or it has expired"
      assert Accounts.get_user_by_name(user.name)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.user_settings_path(conn, :confirm_name, token))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end
end
