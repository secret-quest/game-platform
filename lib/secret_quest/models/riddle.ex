defmodule SecretQuest.Models.Riddle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "riddles" do
    field :description, :string
    field :answer, :string
    field :hash, :string
    field :solved, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(riddle, attrs) do
    riddle
    |> cast(attrs, [:description, :answer, :hash, :solved])
    |> validate_required([:description, :answer, :hash])
    |> unique_constraint(:hash)
  end
end
