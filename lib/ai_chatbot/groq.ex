defmodule AiChatbot.Groq do
  @url "https://api.groq.com/openai/v1/chat/completions"

  def chat(message) do
    api_key = Application.get_env(:ai_chatbot, :groq_api_key)

    if is_nil(api_key) do
      {:error, "Missing GROQ_API_KEY"}
    else
      req =
        Req.new(
          url: @url,
          json: %{
            model: "llama-3.1-8b-instant",
            messages: [
              %{role: "system", content: "You are a helpful assistant."},
              %{role: "user", content: message}
            ]
          },
          headers: [authorization: "Bearer #{api_key}"]
        )

      case Req.post(req) do
        {:ok, %Req.Response{status: 200, body: body}} ->
          parse(body)

        {:ok, %Req.Response{status: status, body: body}} ->
          {:error, "HTTP #{status}: #{inspect(body)}"}

        {:error, %Req.TransportError{reason: reason}} ->
          {:error, reason}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp parse(%{"choices" => [first | _]}) do
    {:ok, first["message"]["content"]}
  end

  defp parse(body) do
    {:error, "unexpected response: #{inspect(body)}"}
  end
end
