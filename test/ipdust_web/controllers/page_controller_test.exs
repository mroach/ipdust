defmodule IpdustWeb.PageControllerTest do
  use IpdustWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Your IP"
  end
end
