defmodule AiChatbotWeb.HealthController do
  use AiChatbotWeb, :controller

  def index(conn, _params) do
    text(conn, "ok")
  end
end
