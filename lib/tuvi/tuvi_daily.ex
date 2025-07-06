defmodule TuviDaily do
  use Ecto.Schema
  import Ecto.Changeset
  alias Tuvi.Repo
  import Ecto.Query, only: [from: 2]

# CREATE TABLE tuvi_daily (
#   id SERIAL PRIMARY KEY,
#   title VARCHAR,
#   date VARCHAR,
#   data TEXT,
#   inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
# );

  schema "tuvi_daily" do
    field :title, :string
    field :date, :string
    field :data, :string
    timestamps()
  end

  def changeset(tuvi_daily, attrs, opts \\ []) do
    tuvi_daily
    |> cast(attrs, [:title, :date, :data])
    |> validate_required([:title, :date, :data])
  end

  def create_tuvi_daily(attrs) do
    # Insert bản ghi mới
    result =
      %TuviDaily{}
      |> changeset(attrs)
      |> Repo.insert()

    # Sau khi insert, giữ lại 3 bản ghi mới nhất, xóa phần còn lại
    keep_ids =
      from(t in TuviDaily,
        order_by: [desc: t.inserted_at],
        select: t.id,
        limit: 3
      )
      |> Repo.all()

    from(t in TuviDaily, where: t.id not in ^keep_ids)
    |> Repo.delete_all()

    result
  end

  def get_latest_tuvi_dailies(limit \\ 3) do
    from(t in TuviDaily,
      order_by: [desc: t.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  def get_by_date() do
    from(t in TuviDaily, order_by: [asc: t.inserted_at], limit: 1)
    |> Repo.one()
  end

  def get_by_date(date) do
    from(t in TuviDaily,
      where: t.date == ^date,
      order_by: [desc: t.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end
end
