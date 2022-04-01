# What is Gigalixir?
Gigalixir is a fully-featured, production-stable platform-as-a-service built just for Elixir that saves you money and unlocks the full power of Elixir and Phoenix without forcing you to build production infrastructure or deal with maintenance and operations. For more information, see https://gigalixir.com.

Try Gigalixir for free without a credit card by following the [Getting Started Guide](https://gigalixir.readthedocs.io/en/latest/getting-started-guide.html).

# What is FunctionServerBasedOnArweave?

Based on Arweave's FaaS system, code snippets written in languages such as Elixir/Rust can be pulled from the Arweave Network and loaded into Runtime to provide functional service support for other applications. Plugin is used for uploading code snippets.

![去中心化FaaS系统的实现-en-zzf (3)](https://tva1.sinaimg.cn/large/e6c9d24egy1h0c241bwi9j21cc0jsq59.jpg)

# How to deploy FunctionServerBasedOnArweave to Gigalixir?

## 0x00 Prerequisites

- For macOS

brew. For help, take a look at the [homebrew documentation](https://docs.brew.sh/Installation).
git. For help, take a look at the [git documentation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

- For Linux

python3. python2 also works, but it is EOL as of January 1st, 2020.
pip3. For help, take a look at the pip documentation.
git. For help, take a look at the git documentation.
For example, run

```
sudo apt-get update
sudo apt-get install -y python3 python3-pip git-core curl
```

- For Windows

python3. python2 also works, but it is EOL as of January 1st, 2020.
pip3. For help, take a look at the pip documentation.
git. For help, take a look at the git documentation.


## 0x01 Install the Command-Line Interface

Next, install the command-line interface. Gigalixir has a web interface at https://console.gigalixir.com/, but you will likely still want the CLI.

- For macOS

```
brew tap gigalixir/brew && brew install gigalixir
```

- For Linux

```
pip3 install gigalixir --user
```

And then make sure the executable is in your path, if it isn’t already.

```
echo 'export PATH=~/.local/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
```

- For windows

```
pip3 install gigalixir --user
```

Make sure the executable is in your path, if it isn’t already.

Verify by running

```
gigalixir --help
```

## 0x02 Create an Account

If you already have an account, skip this step.

```
gigalixir signup
```

## 0x03 Log In

Next, log in. This will grant you an api key. It will also optionally modify your ~/.netrc file so that all future commands are authenticated.

```
gigalixir login
```

Verify by running

```
gigalixir account
```

## 0x04 Prepare Your App

```
https://github.com/WeLightProject/function_server_based_on_arweave
```

## 0x05 Set Up App for Deploys

```
cd function_server_based_on_arweave
APP_NAME=$(gigalixir create -n faasex)
```

Verify that the app was created, by running

```
gigalixir apps
```

Verify that a git remote was created by running

```
git remote -v
```

## 0x06 Specify Versions & Check Configs

- Check `.buildpacks`

```
https://github.com/emk/heroku-buildpack-rust
https://github.com/HashNuke/heroku-buildpack-elixir
https://github.com/gjaldon/heroku-buildpack-phoenix-static
https://github.com/gigalixir/gigalixir-buildpack-mix.git
```

-  Check `elixir_buildpack.config`

```
elixir_version=1.13.3
erlang_version=24.3.2
hook_post_compile="mkdir -p assets/node_modules"
```

- Check `RustConfig`

```
RUST_SKIP_BUILD=1
```

- Check `phoenix_static_buildpack.config`

```
node_version=14.15.4
clean_cache=true
```

- Check `assets/package.json`

```json
{
  "scripts": {
    "deploy": "cd .. && mix assets.deploy && rm -f _build/esbuild"
  }
}
```

- Check `config/prod.exs`

```elixir
## ...

config :function_server_based_on_arweave, FunctionServerBasedOnArweaveWeb.Endpoint,
  http: [port: {:system, "PORT"}], # Possibly not needed, but doesn't hurt
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  server: true

config :function_server_based_on_arweave, FunctionServerBasedOnArweave.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: 2 # Free tier db only allows 4 connections. Rolling deploys need pool_size*(n+1) connections where n is the number of app replicas.

```

Don’t forget to commit if you change something.

```
git add .
git commit -m "assets deploy script"
```

## 0x07 Provision a Database

```
gigalixir pg:create --free
```

Verify by running

```
gigalixir pg
```

## 0x08 Deploy!

Finally, build and deploy.

```
git push gigalixir
```

## 0x09 Run Migrations

```
gigalixir run mix ecto.migrate
# this is run asynchronously as a job, so to see the progress, you need to run
gigalixir logs
```

Run seeds

```
gigalixir run -- mix run priv/repo/seeds.exs
```

## 0x10 Enjoy it!

Wait a minute or two for the app to pass health checks. You can check the status by running

```
gigalixir ps
```

Verify it works
```
curl https://$APP_NAME.gigalixirapp.com/
# or you could also run
# gigalixir open
```

Now you can run `gigalixir open` to open your own website.

![](https://raw.githubusercontent.com/zhenfeng-zhu/pic-go/main/202203241434010.png)

If you get error, please try to clean your build cache and then try agin.

```
git -c http.extraheader="GIGALIXIR-CLEAN: true" push gigalixir
```

## Furthermore

### Set up your custom domain

After first deploy, you can see app by visiting https://$APP_NAME.gigalixirapp.com/ .

but if you want, you can point your own domain such as www.example.com to your app. To do this, run the following command and follow the instructions.

```
gigalixir domains:add www.example.com
```

This will do a few things. It registers your fully qualified domain name in the load balancer so that it knows to direct traffic to your containers. It also sets up SSL/TLS encryption for you and provisions a certificate. 

You can also add domain by visiting `https://console.gigalixir.com/#/apps/` with UI style.

![](https://raw.githubusercontent.com/zhenfeng-zhu/pic-go/main/202204011038713.png)

### Set up your environment variables

All app configuration is done through environment variables. You can get, set, and delete configs using the following commands. Note that setting configs automatically restarts your app.

FaaS admins can use all valid code snippet stored on AR network via `Tx ID` (Code Market will be launched in the future)! Through the `Add new Function by Tx id` page, admins can dynamically pull the code from the Arweave network. Uploading the code is achieved through `dApp/Plugin` which is decoupled from FaaS. We use `System.get_env("ADMIN_PASSWD")` to get ADMIN_PASSWD environment variable.

So that, we can set or unset `ADMIN_PASSWD` like this:

```
gigalixir config
gigalixir config:set ADMIN_PASSWD=bar
gigalixir config:unset ADMIN_PASSWD
```

