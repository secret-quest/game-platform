defmodule SecretQuest.RiddleGenerator do
  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage

  # Ensure your API key is set in the environment variables
  @api_key System.get_env("OPENAI_API_KEY")

  def generate_riddle do
    openai = OpenaiEx.new(@api_key)

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
      {:ok, %{"choices" => [%{"message" => %{"content" => text}}]}} ->
        {:ok, Jason.decode!(text)}

      {:error, reason} ->
        {:error, "Failed to generate riddle: #{reason}"}
    end
  end
end
