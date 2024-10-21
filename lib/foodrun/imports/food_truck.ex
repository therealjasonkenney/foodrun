defmodule Foodrun.Imports.FoodTruck do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias __MODULE__

  schema "food_trucks" do
    field :external_id, :integer
    field :active, :boolean, default: false
    field :name, :string
    field :lat, :float
    field :long, :float
    # These can be blank
    field :address, :string
    field :menu, :string
    field :schedule_url, :string

    timestamps(type: :utc_datetime)
  end

  @type t() :: %__MODULE__{
          id: non_neg_integer() | nil,
          external_id: non_neg_integer() | nil,
          active: boolean() | nil,
          address: String.t() | nil,
          name: String.t() | nil,
          lat: float() | nil,
          long: float() | nil,
          menu: String.t() | nil,
          schedule_url: String.t() | nil
        }

  @type stream() :: Enumerable.t(Changeset.t(t()))

  @doc """
  Builds a query that filters on active.

  Foodtrucks that are active are the ones by default displayed to the user.
  When importing records in `food_trucks`, `active` is set to `false` by default, so that
  if any errors happen while inserting many records (via a stream), we can roll the thing back
  without needing a transaction for 1000s of records at once.
  """
  @spec active?(boolean()) :: Ecto.Query.t()
  def active?(active \\ true) do
    from(f in __MODULE__, where: f.active == ^active)
  end

  @doc false
  @spec changeset_id(Changeset.t(t())) :: pos_integer() | nil
  def changeset_id(changeset) do
    get_field(changeset, :external_id)
  end

  @doc false
  @spec new_changeset(map()) :: Changeset.t(t())
  def new_changeset(attrs) do
    %FoodTruck{}
    |> cast(attrs, [:address, :external_id, :lat, :long, :name, :menu, :schedule_url])
    |> put_change(:active, false)
    |> validate_required([:external_id, :lat, :long, :name])
  end
end
