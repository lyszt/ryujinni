defmodule RyujinWeb.ErrorJSONTest do
  use RyujinWeb.ConnCase, async: true

  test "renders 404" do
    assert RyujinWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert RyujinWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
