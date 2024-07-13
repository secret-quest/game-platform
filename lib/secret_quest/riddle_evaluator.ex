defmodule SecretQuest.RiddleEvaluator do
  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage
  alias SecretQuest.Repos.RiddlesRepo
  # Ensure your API key is set in the environment variables

  def correct_riddle_answer?(hash, answer) do
    riddle = RiddlesRepo.get_riddle_by_hash(hash)
    openai = OpenaiEx.new(Application.get_env(:secret_quest, :openai_api_key))

    chat_req =
      Chat.Completions.new(
        model: "gpt-4o",
        messages: [
          ChatMessage.user("Can you check if this riddle answer is correct

          riddle: #{riddle.description}
          user answer: #{answer}
          riddle answer: #{riddle.answer}

          You return true if the users answer is correct, otherwise false. Return in the following JSON format:
            {
              \"riddle\": {
                \"correct\": \"\"
            }
            ")
        ],
        response_format: %{"type" => "json_object"}
      )

    case Chat.Completions.create(openai, chat_req) do
      {:ok, %{"choices" => [%{"message" => %{"content" => json}}]}} ->
        json = Jason.decode!(json)

        json["riddle"]["correct"] == "true"

      {:error, reason} ->
        IO.inspect("Failed to evaluate riddle: #{reason}")
        :error
    end
  end
end
