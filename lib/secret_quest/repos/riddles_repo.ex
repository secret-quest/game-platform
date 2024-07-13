defmodule SecretQuest.Repos.RiddlesRepo do
  import Ecto.Query, warn: false

  alias SecretQuest.Models.Riddle
  alias SecretQuest.Repo

  def insert_riddle(attrs) do
    %Riddle{}
    |> Riddle.changeset(attrs)
    |> Repo.insert()
  end

  def update_solved_riddle(riddle) do
    riddle
    |> Riddle.changeset(%{solved: true})
    |> Repo.update()
  end

  def get_latest_riddle() do
    Repo.one(
      from r in Riddle, where: r.solved == false, order_by: [desc: r.inserted_at], limit: 1
    )
  end
end
