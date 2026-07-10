defmodule AiChatbotWeb.HealthControllerTest do
  use AiChatbotWeb.ConnCase

  test "GET /health", %{conn: conn} do
    conn = get(conn, ~p"/health")

    assert text_response(conn, 200) == "ok"
  end
end
