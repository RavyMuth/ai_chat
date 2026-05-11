defmodule AiChatbot.Groq do
  @url "https://api.groq.com/openai/v1/chat/completions"

  def chat(message) do
    api_key = Application.get_env(:ai_chatbot, :groq_api_key)

    if is_nil(api_key) do
      {:error, "Missing GROQ_API_KEY"}
    else
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{api_key}"}
      ]

      body =
        Jason.encode!(%{
          model: "llama-3.1-8b-instant",
          messages: [
            %{role: "system", content: "You are a helpful assistant."},
            %{role: "user", content: message}
          ]
        })

      case HTTPoison.post(@url, body, headers, []) do
        {:ok, %{status_code: 200, body: body}} ->
          parse(body)

        {:ok, %{status_code: code, body: body}} ->
          {:error, "HTTP #{code}: #{body}"}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp parse(body) do
    case Jason.decode(body) do
      {:ok, %{"choices" => [first | _]}} ->
        {:ok, first["message"]["content"]}

      error ->
        error
    end
  end
end
