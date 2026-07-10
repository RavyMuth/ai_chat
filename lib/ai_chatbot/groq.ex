defmodule AiChatbot.Groq do
  @url "https://api.groq.com/openai/v1/chat/completions"
  @model "llama-3.1-8b-instant"

  def chat(message) when is_binary(message) do
    with {:ok, api_key} <- api_key(),
         {:ok, message} <- normalize_message(message) do
      req =
        Req.new(
          url: @url,
          receive_timeout: 60_000,
          json: %{
            model: @model,
            messages: [
              %{role: "system", content: "You are a helpful assistant."},
              %{role: "user", content: message}
            ]
          },
          headers: [
            {"authorization", "Bearer #{api_key}"},
            {"content-type", "application/json"}
          ]
        )

      case Req.post(req) do
        {:ok, %Req.Response{status: 200, body: body}} ->
          parse(body)

        {:ok, %Req.Response{status: status, body: body}} ->
          {:error, status, groq_error(body)}

        {:error, %Req.TransportError{reason: reason}} ->
          {:error, 502, "Could not reach Groq: #{inspect(reason)}"}

        {:error, reason} ->
          {:error, 502, "Groq request failed: #{inspect(reason)}"}
      end
    end
  end

  def chat(_message), do: {:error, 400, "Message is required"}

  defp api_key do
    case Application.get_env(:ai_chatbot, :groq_api_key) do
      key when is_binary(key) ->
        key = String.trim(key)

        if key == "" do
          {:error, 503, "Missing GROQ_API_KEY"}
        else
          {:ok, key}
        end

      _key ->
        {:error, 503, "Missing GROQ_API_KEY"}
    end
  end

  defp normalize_message(message) do
    message = String.trim(message)

    if message == "" do
      {:error, 400, "Message is required"}
    else
      {:ok, message}
    end
  end

  defp parse(%{"choices" => [first | _]}) do
    case get_in(first, ["message", "content"]) do
      content when is_binary(content) and content != "" ->
        {:ok, content}

      _content ->
        {:error, 502, "Groq returned an empty response"}
    end
  end

  defp parse(body) do
    {:error, 502, "Unexpected Groq response: #{inspect(body)}"}
  end

  defp groq_error(%{"error" => %{"message" => message}}) when is_binary(message), do: message
  defp groq_error(%{"error" => message}) when is_binary(message), do: message
  defp groq_error(body), do: "Groq API error: #{inspect(body)}"
end
