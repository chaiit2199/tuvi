defmodule FetchDataSource do
  use TuviWeb, :live_component
  alias Jason

  def fetch_data(path) do
    file_path = File.read(to_string(:code.priv_dir(:tuvi)) <> path) || []

    case file_path do
      {:ok, res} ->
        case Jason.decode(res) do
          {:ok, data} -> data
          {:error, _reason} -> %{}
        end

      {:error, _} ->
        %{}
    end
  end

  def fetch_json(path) do
    fetch_data("/json/" <> path)
  end
end
