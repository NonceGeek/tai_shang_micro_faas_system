# FunctionServerBasedOnArweave

<img width="300" alt="image" src="https://user-images.githubusercontent.com/12784118/156332875-41467bba-7ffe-4e86-9248-0440075e338c.png">

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


## Troubleshooting

1. `ERROR 42501 (insufficient_privilege) permission denied to create database`

    Please alter your postgres sql role in terminal, here is a example:

```sh
$ psql
psql (14.2)
Type "help" for help.

lucas=# ALTER USER postgres WITH CREATEDB;
ALTER ROLE
lucas=# \q
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

