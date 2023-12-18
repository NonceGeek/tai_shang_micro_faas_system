defmodule Components.SmartPrompterInteractor do
  alias Components.ExHttp
  @paths %{
    user:
      %{
        register: "api/users/register",
        login: "api/users/log_in",
        get_current_user: "api/current_user"
      },
    chat:
      %{
        topics: "api/topics",
      },
    templates:
      %{
        create: "api/prompt_templates"
      }
  }
  def register(username, password) do
    # TODO.
  end

  # for test
  def register(endpoint) do
    body = %{
      user: %{
        email: Constants.smart_prompter_acct(),
        password: Constants.smart_prompter_pwd()
      }
    }
    path = "#{endpoint}/#{@paths.user.register}"
    ExHttp.http_post(path, body)
  end

  def get_current_user(endpoint) do
    # path = "#{endpoint}/#{@paths.user.get_current_user}"
    # IO.puts inspect path
    # token = get_session(endpoint)
    # ExHttp.http_get(path, token, 3)
    :smart_prompter_user_info
    |> Process.whereis()
    |> Agent.get(fn user_info -> user_info end)
  end

  def login(endpoint) do
    body = %{
      user: %{
        email: Constants.smart_prompter_acct(),
        password: Constants.smart_prompter_pwd()
      }
    }
    path = "#{endpoint}/#{@paths.user.login}"
    ExHttp.http_post(path, body)
  end

  def register_agent() do
    {:ok, agent} = Agent.start_link fn -> [] end
    Process.register(agent, :smart_prompter)
  end

  def register_agent(:smart_prompter_user_info) do
    {:ok, agent} = Agent.start_link fn -> [] end
    Process.register(agent, :smart_prompter_user_info)
  end

  def set_session(endpoint) do
    {
      :ok,
        %{
          email: email,
          id: id,
          token: the_token
        } = the_user_info
    } = login(endpoint)
    pid = Process.whereis(:smart_prompter)
    pid_user_info = Process.whereis(:smart_prompter_user_info)
    if is_nil(pid) do
      register_agent()      
    end

    if is_nil(pid_user_info) do
      register_agent(:smart_prompter_user_info)      
    end

    pid = Process.whereis(:smart_prompter)
    Agent.update(pid, fn token -> the_token end)


    pid_user_info = Process.whereis(:smart_prompter_user_info)
    Agent.update(pid_user_info, fn user_info -> the_user_info end)
  end

  def get_session(endpoint) do

    :smart_prompter
    |> Process.whereis()
    |> Agent.get(fn token -> token end)
  end

    # +--------+
    # | Topics |
    # +--------+

  def list_topics(endpoint) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.chat.topics}"
    ExHttp.http_get(path, token, 3)
  end

  def list_topics(endpoint, topic_id) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.chat.topics}/#{topic_id}"
    ExHttp.http_get(path, token, 3)
  end

  def create_topic(endpoint, content) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.chat.topics}"
    body =
      %{
        topic: %{
          content: content
        }
      }
    ExHttp.http_post(path, body, token, 3)
  end

  def create_topic(endpoint, content, prompt_template_id) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.chat.topics}"
    body =
      %{
        topic: %{
          content: content,
          prompt_template_id: prompt_template_id
        }
      }
    ExHttp.http_post(path, body, token, 3)
  end

  # +-----------+
  # | Templates |
  # +-----------+

  def create_template(endpoint, title, content) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.templates.create}"

    body =
      %{
        prompt_template: %{
          title: title,
          content: content
        }
      }
    ExHttp.http_post(path, body, token, 3)
  end

  def list_template(endpoint) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.templates.create}"
    ExHttp.http_get(path, token, 3)
  end

  def list_template(endpoint, user_id) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.templates.create}?user_id=#{user_id}"
    ExHttp.http_get(path, token, 3)
  end

  def get_template(endpoint, template_id) do
    token = get_session(endpoint)
    path = "#{endpoint}/api/prompt_templates/#{template_id}"
    ExHttp.http_get(path, token, 3)
  end

  # +--------------------+
  # | Funcs about Prompt |
  # +--------------------+

  def impl_vars(prompt, vars) do
    Enum.reduce(vars, prompt, fn {key, value}, acc ->
      String.replace(acc, "{#{key}}", value)
    end)
  end
end
