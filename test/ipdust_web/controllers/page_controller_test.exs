defmodule IpdustWeb.PageControllerTest do
  use IpdustWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Your IP"
  end

  test "GET /json behind proxy", %{conn: conn} do
    response = conn
    |> put_req_header("x-real-ip", "24.34.153.229")
    |> get("/json")

    assert json_response(response, 200)["ip"] == "24.34.153.229"
  end
end
