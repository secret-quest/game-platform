defmodule SecretQuest.RiddleDivider do
  alias SecretQuest.Repos.RiddlesRepo

  def divide_riddle_for_level(level) do
    random_pieces = if level > 10 do
      1
    else
      10 - level
     end
    latest_unsolved_riddle = RiddlesRepo.get_latest_riddle()

    latest_unsolved_riddle.description
    |> String.split(" ")
    |> Enum.chunk_every(3)
    |> Enum.take_random(random_pieces)
    |> Enum.uniq()
    |> Enum.map(&(Enum.join(&1, " ")))
  end
end