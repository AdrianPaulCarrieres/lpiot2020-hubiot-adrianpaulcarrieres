defmodule Hubiot.Iot.Donnee do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:value, :inserted_at]}

  schema "donnees" do
    field :location, :string
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(donnee, attrs) do
    donnee
    |> cast(attrs, [:value, :location])
    |> validate_required([:value, :location])
  end
end
