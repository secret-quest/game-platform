defmodule SecretQuest.Repo.Migrations.AlterDescriptionFieldLength do
  use Ecto.Migration

  def change do
    alter table(:riddles) do
      modify :description, :string, size: 2000
    end
  end
end
