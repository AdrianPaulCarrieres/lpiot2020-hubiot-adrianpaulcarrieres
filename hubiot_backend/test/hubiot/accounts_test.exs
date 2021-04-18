defmodule Hubiot.AccountsTest do
  use Hubiot.DataCase

  alias Hubiot.Accounts
  import Hubiot.AccountsFixtures
  alias Hubiot.Accounts.{User, UserToken}

  describe "get_user_by_name/1" do
    test "does not return the user if the name does not exist" do
      refute Accounts.get_user_by_name("unknown@example.com")
    end

    test "returns the user if the name exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_name(user.name)
    end
  end

  describe "get_user_by_name_and_password/2" do
    test "does not return the user if the name does not exist" do
      refute Accounts.get_user_by_name_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_name_and_password(user.name, "invalid")
    end

    test "returns the user if the name and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_name_and_password(user.name, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires name and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               name: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates name and password when given" do
      {:error, changeset} = Accounts.register_user(%{name: "not valid", password: "not valid"})

      assert %{
               name: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for name and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{name: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).name
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates name uniqueness" do
      %{name: name} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{name: name})
      assert "has already been taken" in errors_on(changeset).name

      # Now try with the upper cased name too, to check that name case is ignored.
      {:error, changeset} = Accounts.register_user(%{name: String.upcase(name)})
      assert "has already been taken" in errors_on(changeset).name
    end

    test "registers users with a hashed password" do
      name = unique_user_name()
      {:ok, user} = Accounts.register_user(valid_user_attributes(name: name))
      assert user.name == name
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :name]
    end

    test "allows fields to be set" do
      name = unique_user_name()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(name: name, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :name) == name
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_name/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_name(%User{})
      assert changeset.required == [:name]
    end
  end

  describe "apply_user_name/3" do
    setup do
      %{user: user_fixture()}
    end

    test "requires name to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_name(user, valid_user_password(), %{})
      assert %{name: ["did not change"]} = errors_on(changeset)
    end

    test "validates name", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_name(user, valid_user_password(), %{name: "not valid"})

      assert %{name: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for name for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_name(user, valid_user_password(), %{name: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).name
    end

    test "validates name uniqueness", %{user: user} do
      %{name: name} = user_fixture()

      {:error, changeset} =
        Accounts.apply_user_name(user, valid_user_password(), %{name: name})

      assert "has already been taken" in errors_on(changeset).name
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_name(user, "invalid", %{name: unique_user_name()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the name without persisting it", %{user: user} do
      name = unique_user_name()
      {:ok, user} = Accounts.apply_user_name(user, valid_user_password(), %{name: name})
      assert user.name == name
      assert Accounts.get_user!(user.id).name != name
    end
  end

  describe "deliver_update_name_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_name_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.name
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_name/2" do
    setup do
      user = user_fixture()
      name = unique_user_name()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_name_instructions(%{user | name: name}, user.name, url)
        end)

      %{user: user, token: token, name: name}
    end

    test "updates the name with a valid token", %{user: user, token: token, name: name} do
      assert Accounts.update_user_name(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.name != user.name
      assert changed_user.name == name
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update name with invalid token", %{user: user} do
      assert Accounts.update_user_name(user, "oops") == :error
      assert Repo.get!(User, user.id).name == user.name
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update name if user name changed", %{user: user, token: token} do
      assert Accounts.update_user_name(%{user | name: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).name == user.name
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update name if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_name(user, token) == :error
      assert Repo.get!(User, user.id).name == user.name
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(user.password)
      assert Accounts.get_user_by_name_and_password(user.name, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.name
      assert user_token.context == "confirm"
    end
  end

  describe "confirm_user/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "confirms the name with a valid token", %{user: user, token: token} do
      assert {:ok, confirmed_user} = Accounts.confirm_user(token)
      assert confirmed_user.confirmed_at
      assert confirmed_user.confirmed_at != user.confirmed_at
      assert Repo.get!(User, user.id).confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm with invalid token", %{user: user} do
      assert Accounts.confirm_user("oops") == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not confirm name if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_user(token) == :error
      refute Repo.get!(User, user.id).confirmed_at
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.name
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user} = Accounts.reset_user_password(user, %{password: "new valid password"})
      assert is_nil(updated_user.password)
      assert Accounts.get_user_by_name_and_password(user.name, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
