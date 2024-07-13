defmodule SecretQuest.RiddleGenerator do
  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage
  alias SecretQuest.Repos.RiddlesRepo
  # Ensure your API key is set in the environment variables

  def generate_riddle do
    openai = OpenaiEx.new(Application.get_env(:secret_quest, :openai_api_key))

    chat_req =
      Chat.Completions.new(
        model: "gpt-4o",
        messages: [
          ChatMessage.user(
            "Can you generate a long riddle with an answer and return it in JSON format?
            The JSON returned looks like this:
            {
              \"riddle\": {
                \"description\": \"\",
                \"answer\": \"\"
            }
            "
          )
        ],
        response_format: %{"type" => "json_object"}
      )

    case Chat.Completions.create(openai, chat_req) do
      {:ok, %{"choices" => [%{"message" => %{"content" => json}}]}} ->
        json = Jason.decode!(json)
        RiddlesRepo.insert_riddle(%{
          description: json["riddle"]["description"],
          answer: json["riddle"]["answer"],
          hash: :crypto.hash(:sha256, json["riddle"]["description"]) |> Base.encode16(),
          solved: false
        })
        :ok

      {:error, reason} ->
        IO.inspect("Failed to generate riddle: #{reason}")
        :error
    end
  end
end
