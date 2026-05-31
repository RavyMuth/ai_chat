defmodule AiChatbotWeb.ChatController do
  use AiChatbotWeb, :controller

  alias AiChatbot.Groq

  def chat(conn, %{"message" => message}) do
    case Groq.chat(message) do
      {:ok, reply} ->
        json(conn, %{reply: reply})

      {:error, error} ->
        conn
        |> put_status(500)
        |> json(%{error: inspect(error)})
    end
  end
end
