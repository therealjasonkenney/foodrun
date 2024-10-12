defmodule Foodrun.Repo.Migrations.CreateFoodTrucks do
  use Ecto.Migration

  # This table stores the ingres data from the csv.
  # I am only using what data I think I need, you
  # may notice this has some duplication with the generated
  # columns, because the number of records remains small 
  # I have the space to allow for a simpler interface between
  # elixir and postgres, ecto does not need to care as much about
  # the postgis and textsearch functions at least with inserting data.
  def change do
    execute "CREATE EXTENSION IF NOT EXISTS postgis;"

    create table(:food_trucks) do
      add :external_id, :integer,
        null: false,
        comment: "This is the locationid SF city uses in what seems like a primary key."

      add :name, :string, null: false, comment: "Company name, non unique"

      add :menu, :text,
        comment: "The raw text used to describe food, this can be displayed in the UI."

      add :address, :string,
        comment:
          "The street address, we don't need city, zip as the data is city specific, used for UI."

      add :lat, :float,
        null: false,
        comment: "The latitude coordinates, we use float because GIS likes float."

      add :long, :float,
        null: false,
        comment: "The longitude coordinates, we use float because GIS likes float."

      add :schedule_url, :string,
        comment: "A URL to the truck schedule in PDF format hosted by San Fran."

      add :active, :boolean,
        default: false,
        null: false,
        comment: "If their permit is active... i.e. not expired."

      add :location, :"geography(POINT, 4326)",
        generated:
          "ALWAYS AS (ST_GeogFromText('SRID=4326;POINT(' || long || ' ' || lat || ')')) STORED",
        comment: "So we don't need to input the point type manually in ecto."

      add :searchable, :tsvector,
        generated: """
          ALWAYS AS (
            setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
            setweight(to_tsvector('english', regexp_replace(coalesce(menu, ''), '[[:punct:]]', '', 'g')), 'B')
          ) STORED
        """,
        comment: "For search efficiency."

      timestamps(type: :utc_datetime)
    end

    create index("food_trucks", [:external_id], unique: true)
    create index("food_trucks", [:active])
    create index("food_trucks", [:location], using: "GIST")
    create index("food_trucks", [:searchable], using: "GIN")
  end
end
