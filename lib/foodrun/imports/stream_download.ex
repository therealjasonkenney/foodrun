defmodule Foodrun.Imports.StreamDownload do
  require Logger

  @doc """
  Begins and returns a `Stream` for downloading a remote resource and converting it into a streamed
  file chunked by newline.

  **Warning:** This can cause the entire file to be loaded in memory if there are no newlines.

  Raises on error, reasons are derived from `:hackney.stream_body/1` and `:hackney.get/1`.

  **Note:** This method does not have test coverage, it is planned to be added in the future when
            there is time to refactor this to be ammenable towards mocking out the http connection.
  """
  @spec get!(URI.t()) :: Enumerable.t(String.t()) | no_return
  def get!(url) when is_binary(url) do
    Stream.resource(on_init(url), &handle_next_chunk/1, on_finish(url))
    # Garuntee at least ONE newline.
    |> Stream.concat(["\n"])
    # Map to individual characters.
    |> Stream.flat_map(&String.codepoints/1)
    # Partition at every newline.
    |> Stream.chunk_by(&(&1 == "\n"))
    # Join each line into a string.
    |> Stream.map(&List.to_string/1)
  end

  defp handle_next_chunk({client, prev_size} = msg) do
    case :hackney.stream_body(client) do
      {:ok, data} ->
        current_size = prev_size + byte_size(data)

        {
          [data],
          {client, current_size}
        }

      :done ->
        {:halt, msg}

      {:error, reason} ->
        raise reason
    end
  end

  defp on_finish(url) when is_binary(url) do
    fn {client, size} ->
      Logger.info("Finished download", bytes: size, url: url)

      :hackney.close(client)
    end
  end

  defp on_init(url) when is_binary(url) do
    fn ->
      url
      |> :hackney.get()
      |> set_initial_state()
    end
  end

  # They don't provide content-length
  defp set_initial_state({:ok, _status, _headers, client}) do
    current_size = 0

    {client, current_size}
  end

  defp set_initial_state({:error, reason}) do
    raise reason
  end
end
