defmodule DailyGeminiAPI do
  use GenServer
  alias GeminiAPI
  alias TuviDaily

  # Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  # Server Callbacks
  def init(state) do
    {:ok, state}
  end

  def handle_info(:work, state) do
    create_posts()  # Call GeminiAPI and create 3 posts
    {:noreply, state}
  end

  # This function can be called by SchedEx
  def work do
    create_posts()  # This will be called every time the scheduled job runs
  end

  defp create_posts do
    # Tạo câu hỏi với danh mục
    tomorrow = Date.utc_today() |> Date.add(2) |> Calendar.strftime("%d-%m-%Y")
    question = "Viết tử vi ngày #{tomorrow}"
    case GeminiAPI.call_api(question) do
      {:ok, raw_questions} ->
        raw_questions
        |> parse_questions()

        # Thêm trường danh mục vào dữ liệu
        case GeminiAPI.call_api(question) do

          {:ok, answer} ->
            if String.starts_with?(answer, "[\n{\n\"") do
              case Jason.decode(answer) do
                {:ok, decoded} ->

                  case TuviDaily.create_tuvi_daily(%{
                    title: "Dự báo vận mệnh ngày #{tomorrow}",
                    date: tomorrow,
                    data: answer
                  }) do
                    {:ok, disease} -> disease
                    {:error, changeset} -> IO.puts("❌ DB error: #{inspect(changeset)}")
                  end

                {:error, _reason} ->
                  IO.puts("⚠️ JSON decode failed, skipping")
              end
            else
              IO.puts("⚠️ Bỏ qua vì format không đúng")
            end

          {:error, reason} ->
            IO.puts("❌ GeminiAPI answer error: #{reason}")
        end

      {:ok, _} -> IO.puts("❌ Unexpected structure, expected a string but got a different format.")
      {:error, {:api_error, status_code, error_body}} ->
        error_message = "API error: #{status_code} - #{error_body}"
        IO.puts("❌ #{error_message}")

      {:error, reason} -> IO.puts("❌ GeminiAPI question fetch error: #{inspect(reason)}")
    end
  end

  defp parse_questions(text) do
    text
    |> String.split("\n")  # Tách chuỗi thành từng dòng
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/\*\*/, "")               # Loại bỏ dấu sao ** nếu có
      |> String.trim()                             # Loại bỏ khoảng trắng thừa
    end)
    |> Enum.uniq()  # Loại bỏ các câu hỏi trùng lặp

  end

  def decode_json(json_string) when is_binary(json_string) do
    case Jason.decode(json_string) do
      {:ok, list} when is_list(list) -> list
      {:ok, map} when is_map(map) -> [map] # fallback nếu JSON là 1 map
      {:error, reason} ->
        IO.puts("❌ JSON decode error: #{inspect(reason)}")
        []
    end
  end

  def decode_json(_), do: []
end
