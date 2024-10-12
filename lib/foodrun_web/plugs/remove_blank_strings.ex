defmodule FoodrunWeb.Plugs.RemoveBlankStrings do
  def init(param_name), do: param_name

  def call(conn, param_name) do
    if has_blank?(conn, param_name) do
      conn
      |> strip_blank(param_name)
    else
      conn
    end
  end

  defp has_blank?(%Plug.Conn{params: params}, param_name) do
    case Map.fetch(params, param_name) do
      # We have a string so test if its just whitespace.
      # String.trim will strip a string of all leading/trailing whitespace
      # so if a trimed string is "" then its blank.
      {:ok, value} when is_binary(value) ->
        String.trim(value) === ""

      # Its there and null, so its blank.
      {:ok, nil} ->
        true

      :error ->
        # Not existing means we don't need to do anything
        false
    end
  end

  defp strip_blank(%Plug.Conn{params: old_params} = conn, param_name) do
    new_params = Map.delete(old_params, param_name)

    conn
    |> Map.replace(:params, new_params)
  end
end
