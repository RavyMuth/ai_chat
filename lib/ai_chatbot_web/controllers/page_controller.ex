defmodule AiChatbotWeb.PageController do
  use AiChatbotWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
