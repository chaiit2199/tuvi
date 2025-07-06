defmodule GeminiAPI do
  require Logger

  def call_api(prompt) do
    # Kiểm tra và chuyển đổi chuỗi thành danh sách câu hỏi nếu cần
    prompt = if is_bitstring(prompt) do
      prompt
      |> String.split("\n")  # Tách chuỗi thành danh sách nếu prompt là chuỗi
      |> Enum.filter(fn line -> String.trim(line) != "" end)  # Loại bỏ các dòng trống
    else
      prompt  # Nếu prompt đã là danh sách, giữ nguyên
    end

    # Loại bỏ phần "Câu hỏi X:" trong các câu hỏi
    prompt_without_questions = Enum.map(prompt, fn question ->
      String.replace(question, ~r/^Câu hỏi \d+: /, "")  # Loại bỏ "Câu hỏi X: "
    end)

    # Loại bỏ các câu hỏi trùng lặp
    prompt_without_questions = Enum.uniq(prompt_without_questions)

    prompt_with_format = """
     [
        {
          Giới thiệu: (Một câu giật tít, con giáp nên thận trọng, giờ không tốt)
        },
        {
          Ngày dương lịch: (Giới thiệu về ngày dương lịch, Thứ mấy)
        },
        {
          Ngày âm lịch: (Giới thiệu về ngày âm lịch)
        },
        {
          Mô tả: (Giới thiệu về ngày này, những điều cần lưu ý trong ngày)
        },
        {
          Nên làm trong ngày hôm nay: (Các công việc nên làm ngày này, cách nhau bởi dấu ",")
        },
        {
          Không nên làm hôm nay: (Các công việc không nên làm ngày này, cách nhau bởi dấu ",")
        },
        {
          Giờ tốt: (Giờ tốt trong ngày này)
        },
        {
          Cẩn thận: (Con giáp nên cẩn thận ngày này)
        },
         {
          Lời khuyên: (Lời khuyên tử vi ngày này)
        }
      ]

    #{Enum.join(prompt_without_questions, "\n")}
    """
    api_key = Application.get_env(:tuvi, :API_KEY_GEMINI)
    url_gemini = Application.get_env(:tuvi, :URL_GEMINI)

    url = "#{url_gemini}#{api_key}"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(%{
      "contents" => [
        %{
          "parts" => [
            %{
              "text" => prompt_with_format
            }
          ]
        }
      ]
    })
    options = [timeout: 15_000, recv_timeout: 15_000]

    case HTTPoison.post(url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"candidates" => [%{"content" => %{"parts" => [%{"text" => response_text} | _]}}]}} ->
            {:ok, parse_response_text(response_text)}  # Gọi hàm parse_response_text

          {:ok, _decoded_response} ->
            Logger.error("Unexpected JSON structure")
            {:error, :unexpected_structure}

          {:error, %Jason.DecodeError{}} ->
            Logger.error("Response body is not valid JSON: #{response_body}")
            {:error, :invalid_json}

          {:error, error} ->
            Logger.error("JSON Decode Error: #{inspect(error)}")
            {:error, :json_decode_error}
        end
      {:ok, %HTTPoison.Response{status_code: status_code, body: error_body}} ->
        Logger.error("API: #{status_code} - #{error_body}")
        {:error, {:api_error, status_code, error_body}}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison: #{inspect(reason)}")
        {:error, {:httpoison_error, reason}}
    end
  end

  # Định nghĩa hàm parse_response_text để xử lý chuỗi response_text trả về
  defp parse_response_text(response_text) do
    response_text
    |> String.replace("```json", "")
    |> String.replace("```", "")
    |> String.split("\n")
    |> Enum.filter(fn line ->
      String.trim(line) != ""  # Loại bỏ các dòng trống
    end)
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/^Câu hỏi \d+:\s*/, "")  # Loại bỏ "Câu hỏi X:" với khoảng trắng sau dấu ":"
      |> String.trim()  # Loại bỏ khoảng trắng thừa
    end)
    |> Enum.join("\n")  # Kết hợp lại các dòng đã xử lý
  end

end
