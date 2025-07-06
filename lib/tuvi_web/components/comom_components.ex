defmodule CommonComponents do
  def batch_string(string) do
    (string || "")
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace("đ", "d")
    |> String.replace(~r/\p{Mn}/u, "")       # Bỏ dấu tiếng Việt
    |> String.replace(~r/[^a-z0-9\s]/u, "")  # Bỏ dấu câu và ký tự đặc biệt
    |> String.replace(~r/\s+/, "-")
  end


  def get_params_tuvi(ngay_sinh_string) when is_binary(ngay_sinh_string) do
    # Parse từ "02/01/1999" → Date struct
    case parse_date(ngay_sinh_string) do
      {:ok, %Date{day: ngay, month: thang, year: nam_sinh}} ->
        con_giap = [
          "Rat", "Ox", "Tiger", "Cat", "Dragon", "Snake",
          "Horse", "Goat", "Monkey", "Rooster", "Dog", "Pig"
        ]

        cung_hoang_dao = [
          {"Capricorn", 1, 1, 1, 19},
          {"Aquarius", 1, 20, 2, 18},
          {"Pisces", 2, 19, 3, 20},
          {"Aries", 3, 21, 4, 19},
          {"Taurus", 4, 20, 5, 20},
          {"Gemini", 5, 21, 6, 20},
          {"Cancer", 6, 21, 7, 22},
          {"Leo", 7, 23, 8, 22},
          {"Virgo", 8, 23, 9, 22},
          {"Libra", 9, 23, 10, 22},
          {"Scorpio", 10, 23, 11, 21},
          {"Sagittarius", 11, 22, 12, 21},
          {"Capricorn", 12, 22, 12, 31}
        ]

        nam_hien_tai = Date.utc_today().year
        tuoi = nam_hien_tai - nam_sinh
        chi_so = rem(nam_sinh - 4, 12)
        con_giap_cua_ban = Enum.at(con_giap, chi_so)

        {ten_cung, _, _, _, _} =
          Enum.find(cung_hoang_dao, fn {_, m1, d1, m2, d2} ->
            (thang == m1 and ngay >= d1) or (thang == m2 and ngay <= d2)
          end)

          %{tuoi: tuoi, con_giap_cua_ban: con_giap_cua_ban, ten_cung: ten_cung}
      {:error, _} ->
        %{}
        IO.puts("Lỗi: Ngày sinh không đúng định dạng dd/mm/yyyy.")
    end
  end

  defp parse_date(str) do
    case String.split(str, "/") do
      [dd, mm, yyyy] ->
        with {d, ""} <- Integer.parse(dd),
             {m, ""} <- Integer.parse(mm),
             {y, ""} <- Integer.parse(yyyy),
             {:ok, date} <- Date.new(y, m, d) do
          {:ok, date}
        else
          _ -> {:error, :invalid_date}
        end

      _ -> {:error, :invalid_format}
    end
  end

end
