defmodule Hubiot.IotTest do
  use Hubiot.DataCase

  alias Hubiot.Iot

  describe "donnees" do
    alias Hubiot.Iot.Donnee

    @valid_attrs %{number: 42}
    @update_attrs %{number: 43}
    @invalid_attrs %{number: nil}

    def donnee_fixture(attrs \\ %{}) do
      {:ok, donnee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Iot.create_donnee()

      donnee
    end

    test "list_donnees/0 returns all donnees" do
      donnee = donnee_fixture()
      assert Iot.list_donnees() == [donnee]
    end

    test "get_donnee!/1 returns the donnee with given id" do
      donnee = donnee_fixture()
      assert Iot.get_donnee!(donnee.id) == donnee
    end

    test "create_donnee/1 with valid data creates a donnee" do
      assert {:ok, %Donnee{} = donnee} = Iot.create_donnee(@valid_attrs)
      assert donnee.number == 42
    end

    test "create_donnee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Iot.create_donnee(@invalid_attrs)
    end

    test "update_donnee/2 with valid data updates the donnee" do
      donnee = donnee_fixture()
      assert {:ok, %Donnee{} = donnee} = Iot.update_donnee(donnee, @update_attrs)
      assert donnee.number == 43
    end

    test "update_donnee/2 with invalid data returns error changeset" do
      donnee = donnee_fixture()
      assert {:error, %Ecto.Changeset{}} = Iot.update_donnee(donnee, @invalid_attrs)
      assert donnee == Iot.get_donnee!(donnee.id)
    end

    test "delete_donnee/1 deletes the donnee" do
      donnee = donnee_fixture()
      assert {:ok, %Donnee{}} = Iot.delete_donnee(donnee)
      assert_raise Ecto.NoResultsError, fn -> Iot.get_donnee!(donnee.id) end
    end

    test "change_donnee/1 returns a donnee changeset" do
      donnee = donnee_fixture()
      assert %Ecto.Changeset{} = Iot.change_donnee(donnee)
    end
  end
end
