defmodule IpdustWeb.PageControllerTest do
  use IpdustWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hostname"
  end

  test "GET / behing proxy server", %{conn: conn} do
    response =
      conn
      |> put_req_header("via", "proxy.baddudes.net")
      |> get("/")

    assert html_response(response, 200) =~ "proxy-warning"
  end

  test "GET /json behind load balancer", %{conn: conn} do
    response =
      conn
      |> put_req_header("x-real-ip", "24.34.153.229")
      |> get("/json")

    assert json_response(response, 200)["ip"] == "24.34.153.229"
  end

  # Not working on CI. GeoIP should be mocked out before doing this.
  # since expecing that IP to always be in the US is just asking for trouble.
  @tag skip: true
  test "GET /json country info", %{conn: conn} do
    response =
      conn
      |> put_req_header("x-real-ip", "24.34.153.229")
      |> get("/json")

    expected = %{"name" => "United States", "code" => "US"}

    assert json_response(response, 200)["country"] == expected
  end

  test "GET /json behind proxy", %{conn: conn} do
    response =
      conn
      |> put_req_header("via", "proxy.baddudes.net")
      |> get("/json")

    assert json_response(response, 200)["proxied"] == true
  end
end
