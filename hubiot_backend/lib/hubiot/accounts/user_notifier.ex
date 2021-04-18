defmodule Hubiot.Accounts.UserNotifier do
  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper name or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, body) do
    require Logger
    Logger.debug(body)
    {:ok, %{to: to, body: body}}
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.name, """

    ==============================

    Hi #{user.name},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.name, """

    ==============================

    Hi #{user.name},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user name.
  """
  def deliver_update_name_instructions(user, url) do
    deliver(user.name, """

    ==============================

    Hi #{user.name},

    You can change your name by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
