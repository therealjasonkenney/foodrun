# Foodrun

A not-so-useful foodtruck search service, for San Fran.

## Deploying

This service assumes that deployment is done
via docker-compose on a local machine.

* It assumes that it runs behind a proxy such as
caddy.

* Install Docker https://docs.docker.com/engine/install/
* Write a docker-compose.yml file

For example:
```
version: "3.7"

services:
  caddy:
    image: caddy:2.8.4-alpine
    restart: unless-stopped
    command: "caddy reverse-proxy --from localhost --to app:4000"
    cap_add:
      - NET_ADMIN
    ports:
      - "443:443"
      - "443:443/udp"

  db:
    image: postgis/postgis:12-3.4-alpine
    environment:
      POSTGRES_USER: "foodrun"
      POSTGRES_DB: "foodrun"
      POSTGRES_PASSWORD: "foodrun"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U foodrun -d foodrun"]
      interval: 10s
      retries: 5
      start_period: 30s
      timeout: 10s

  app:
    image: ghcr.io/therealjasonkenney/foodrun:v1.0.0
    restart: unless-stopped
    environment:
      DATABASE_URL: "ecto://foodrun:foodrun@db/foodrun"
      PHX_HOST: "localhost"
      DNS_CLUSTER_QUERY: "foodrun"
      OFFICE_LONG: "-122.38453073422282"
      OFFICE_LAT: "37.755030726766726"
      SECRET_KEY_BASE: ruomyg6OcOdTewxvi2OeYo/fOMVcD9I3H+eER3jlO4SFu6yyD50YLV/AI9XlU5S3
    hostname: foodrun
    init: true
    scale: 2
    depends_on:
      db:
        condition: service_healthy

      migrations:
        condition: service_completed_successfully

  migrations:
    image: ghcr.io/therealjasonkenney/foodrun:v1.0.0
    command: "/app/bin/migrate"
    environment:
      DATABASE_URL: "ecto://foodrun:foodrun@db/foodrun"
    hostname: foodrun
    depends_on:
      db:
        condition: service_healthy
```

* Spin it up via `docker compose up`
* Visit the site (In this case https://localhost )

### Further Reading
* Caddy https://caddyserver.com
* PostGIS Docker https://hub.docker.com/r/postgis/postgis
* Elixir Releases https://hexdocs.pm/elixir/config-and-releases.html
* Docker Compose https://docs.docker.com/compose/

### Environment Variables

These environment variables are required:

| Name              | Description                                              | Example                              |
| ----------------- | -------------------------------------------------------- | ------------------------------------ |
| `DATABASE_URL`    | The connection url for the postgres database.            | `postgres://USER:PASS@HOST/DATABASE` |
| `PHX_HOST`        | The external host that users enter into their browser    | `example.com`                        |
| `SECRET_KEY_BASE` | This is used to sign/envrypt cookies and other secrets.  | Use `mix phx.gen.secret`             |
| `OFFICE_LAT`      | Latitude coordinate for the origin of geo-search queries | `38.454654456`                       |
| `OFFICE_LONG`     | Longitude coordinate for the origin of geo-search queries| `-122.35676575`                      |

These environment variables are optional:

| Name                | Description                                              | Example                              |
| ------------------- | -------------------------------------------------------- | ------------------------------------ |
| `DNS_CLUSTER_QUERY` | The DNS host used so multiple nodes can find each other. | Defaults to `false`, which disables the service. |
| `MAXIMUM_METERS`    | The maximum distance from the origin (for trucks)        | Defaults to `3000` meters (`1.8` mi) |
| `MAXIMUM_TRUCKAGE`  | The maximum number of trucks displayed on the page.      | Defaults to `20`   |
| `PHX_PORT`          | The TCP port your HTTP server will listen on.            | Defaults to `4000` |
| `POOL_SIZE`         | The database connection pool size.                       | Defaults to `10`. |

## Process / Design

When looking over the ask for this project there were three aspects I considered:
* Importing the data from the csv dump San Fran provides, because seed data is a difficult task but
very important for most projects.
* Limiting the food trucks returned by walking distance (3000 meters is around 1.8 miles) because I wanted to
learn more about PostGIS.
* Text search the menu, because a basic form is easy with Postgres, and I've used tsvectors quite a bit before.

### The Importer
After viewing download / decode recipies online I decided to use a GenServer to stream the
download, this uses one of Elixir's advantages, the ease of background tasks.

I seperated it into `Imports.StreamDownload`, `Imports.ImportTask` and `FoodTrucks.SanFran` because I felt that this
was the best for maintenance.
* Having the decoding portion in its own module means we could add other decoders.
* Having the downloader in its own module means other sources can be added. It also means refactoring to make
it more testable is easier due to the rest of the import not caring about the downloader's internals.
* The task is its own GenServer, this is standard pattern in Elixir, it puts and isolates all the scheduling portion
of the task in one place, and fits with the GenServer API Phoenix uses.

However, this task proved the most difficult and took more than three hours. Unexpected issues were:
* Despite online blogs, the csv decoder does not appreciate the newlines being removed from the stream.
* San Fran's API for this csv download does not provide a `Content-Size` header.
* It took some time due to Stream.transform/3 not being the most straightforward in visualizing what is happening,
  in hindsight I may have been better at using some form of Consumer/Producer pattern with messages.
* This was an increase in scope, as I initialy thought the downloader aspect was adjusting code found on
  the internet.
* I don't regret it however, as I learned a bit more on how :hackney works `:)`
* Improvements include adding actual Telemetry, a small amount of refactoring to enable testing (I think seperating the Stream.resource from the transform would let me test the transform piece.)

### The web page.

The only page used lists the trucks, and allows for typing a search query, which reloads the page.
I did not spend too much time on this portion, just enough so they display and do **something**, but
it could use some improvements:

* Listing actual distance, which requires playing with the select query and the schema.
* Grouping food trucks by their name.
* Treating the menu item as an actual list, I only noticed it was a list from the `:` after the fact,
  but postgres supports arrays, and an array search could be easier.
* Because of the above two requiring a slightly different schema, we could split the context and have
  a model for reading via website, and one for the imports.

### Service
There isn't much time to build a fully production ready service, I went with
docker-compose on local because it means I don't have to spin up AWS or heroku, or fly.io.
You can just grab the docker-compose, edit and then run it.

* Though I would like to add some form of telemetry/log service to emulate what you
  can get with Datadog or AWS. This would mean adding Prometheus or looking into using the
  Phoenix Dashboard for the prod version (just have to read up on any security implications)

* I would also like to tweak the runtime so its more flexible, if someone **wants** to run this
bare metal, or in fargate or k8s, support should be placed in it.

## Development

This has only been iterated on one machine, so the following is the best path
scenario for setting up your machine to work on this code, or to run it locally.

Source Documentation: https://therealjasonkenney.github.io/foodrun

### Dependencies

For my own setup I use:
* **OS:** MacOS `14.6.1` on x86
* Homebrew to install OTP https://brew.sh
* `asdf` to install Elixir https://github.com/asdf-vm/asdf-elixir 

Your own setup may differ, so I will list out the top level dependencies for this project,
the reason I used homebrew for OTP is due to it having a variety of different dependencies based on
what OS and architecture you are using, so I **reccommend** using a package manager. (The asdf plugin does
not resolve those dependencies)

|              |          |                          |                                                  |
| ------------ | -------- | ------------------------ | ------------------------------------------------ |
| **OTP**      | `27`     | `brew install erlang@27` | Erlang OTP runtime needed for Elixir             |
| **Elixir**   | `1.17.3` | `asdf install`           | The programming language used for this server.   |
| **Postgres** | `17`     | Used Postgres.app https://postgresapp.com | The database this server uses.  |
| **PostGIS**  | `3.5`    | Included in Postgres.app | Used for geographic searches                     |

### Starting the server

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Running Tests

You can run tests with `mix test`.

### Styling

This project uses `mix format` to enforce a basic default style.

## Learn more

  * Erlang: https://www.erlang.org
  * Elixir: https://elixir-lang.org
  * Postgres: https://www.postgresql.org
  * PostGIS: https://postgis.net
  * Phoenix Framework: https://www.phoenixframework.org/
  * Origin of this project: https://github.com/peck/engineering-assessment
