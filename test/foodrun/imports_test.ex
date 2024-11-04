defmodule Foodrun.ImportsTest do
  use Foodrun.DataCase

  alias Foodrun.Imports

  describe "imports" do
    test "import imports data" do
      {:ok, pid} = Imports.start_mock_server(4009)

      {status, insert_count} = Imports.import(:san_fran, "http://localhost:4009/test.csv")

      Imports.stop_mock_server(pid)

      assert {:ok, 1} == {status, insert_count}
    end
  end
end
