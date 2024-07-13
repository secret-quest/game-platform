defmodule SecretQuest.Repo.Migrations.Riddles do
  use Ecto.Migration

  def change do
    create table(:riddles) do
      add :description, :string
      add :answer, :string
      add :hash, :string
      add :solved, :boolean, default: false
      timestamps()
    end

    unique_index(:riddles, [:hash])
  end
end
