defmodule AiChatbotWeb.ChatController do
  use AiChatbotWeb, :controller

  alias AiChatbot.Groq

  def chat(conn, %{"message" => message}) do
    case Groq.chat(message) do
      {:ok, reply} ->
        json(conn, %{reply: reply})

      {:error, status, error} ->
        conn
        |> put_status(status)
        |> json(%{error: error})
    end
  end

  def chat(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Message is required"})
  end
end
