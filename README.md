# Foodrun

## Development

This has only been iterated on one machine, so the following is the best path
scenario for setting up your machine to work on this code, or to run it locally.

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
