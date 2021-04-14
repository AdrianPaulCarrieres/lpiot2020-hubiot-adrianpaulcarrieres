defmodule Hubiot.Iot.Donnee do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:number, :location]}

  schema "donnees" do
    field :number, :integer
    field :location, :string

    timestamps()
  end

  @doc false
  def changeset(donnee, attrs) do
    donnee
    |> cast(attrs, [:number, :location])
    |> validate_required([:number, :location])
  end
end
