defmodule TuviController do
   alias TuviDaily

  def get_latest do
    TuviDaily.get_latest_tuvi_dailies()
    |> Enum.map(fn item ->
      item
      |> Map.from_struct()
      |> Map.drop([:__meta__, :__struct__, :inserted_at])
      |> Map.update!(:data, &format_data/1)
      |> Map.update!(:updated_at, &format_date/1)
    end)
  end

  def get_tuvi_by_date(date) do
    case TuviDaily.get_by_date(date) do
      nil -> TuviDaily.get_by_date()
      tuvi -> tuvi
    end
    |> IO.inspect()
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__struct__, :inserted_at])
    |> Map.update!(:data, &format_data/1)
    |> Map.update!(:updated_at, &format_date/1)
  end

  defp format_data(data) do
    data
    |> Jason.decode!()
    |> Enum.reduce(%{}, fn map, acc ->
      {k, v} = Enum.at(Map.to_list(map), 0)

      normalized_key =
        k
          |> CommonComponents.batch_string()

      acc
      |> Map.put(normalized_key, k)
      |> Map.put("#{normalized_key}", v)
    end)
  end

  defp format_date(datetime) do
    datetime
    |> NaiveDateTime.to_date()
    |> Calendar.strftime("%d/%m/%Y")
  end

end
