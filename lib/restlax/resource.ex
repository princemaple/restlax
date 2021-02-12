defmodule Restlax.Resource do
  @default_actions ~w(index show create update delete)a
  @can_be_singular [false, true, false, true, false]

  @moduledoc """
  ## Rest Resource builder

  ### Options

  * `:endpoint` - required, string
  * `:singular` - defaults to `false`, boolean
  * `:only` - list of default actions to generate, defaults to `#{inspect(@default_actions)}`
  * `:except` - list of default actions to exclude, defaults to `[]`
  * `:create_method` - HTTP verb to use for `create` action, defaults to `:post`,
  sometimes :`put` is used
  * `:update_method` - HTTP verb to use for `update` action, defaults to `:put`,
  a common alternative is `:patch`

  ### Example

      defmodule MyResource do
        use Restlax.Resource,
          endpoint: "my-resource"
      end
  """

  @type action :: :index | :show | :create | :update | :delete
  @type option ::
          {:endpoint, String.t()}
          | {:singular, boolean()}
          | {:only, [action()]}
          | {:except, [action()]}
          | {:create_method, :post | :put}
          | {:update_method, :put | :patch}

  @type action_body() :: map() | keyword() | Tesla.Multipart.t() | %Stream{} | binary()
  @type action_options() :: [Tesla.option() | {:client, module()} | {:params, keyword()}]

  @spec __using__(opts :: [option()]) :: Macro.t()
  defmacro __using__(opts) do
    endpoint = Keyword.fetch!(opts, :endpoint)
    singular = Keyword.get(opts, :singular, false)

    actions = Keyword.get(opts, :only, @default_actions) -- Keyword.get(opts, :except, [])

    actions_method = [
      :get,
      :get,
      Keyword.get(opts, :create_method, :post),
      Keyword.get(opts, :update_method, :put),
      :delete
    ]

    action_functions = build_action_functions(singular, actions, actions_method)

    quote do
      @endpoint unquote(endpoint)

      unquote(action_functions)

      @spec path_for(term(), [{:action, String.t()}]) :: String.t()
      def path_for(id, opts \\ []) do
        [@endpoint, id, opts[:action]]
        |> Enum.reject(&is_nil/1)
        |> Enum.map(&to_string/1)
        |> Path.join()
      end

      @spec client(Restlax.Resource.action_options()) :: module()
      def client(opts \\ []) do
        Restlax.Resource.client(__MODULE__, opts)
      end
    end
  end

  @doc false
  def client(module, opts \\ []) do
    if custom_client = opts[:client] do
      custom_client
    else
      app =
        case :application.get_application(module) do
          {:ok, app} ->
            app

          undefined ->
            undefined
        end

      :persistent_term.get({app, :client})
    end
  end

  @spec handle_options(opts :: Restlax.Resource.action_options()) :: [Tesla.option()]
  def handle_options(opts) do
    case opts[:params] do
      nil -> opts
      params -> Keyword.update(opts, :opts, [path_params: params], &[{:path_params, params} | &1])
    end
  end

  defp build_action_functions(singular, actions, actions_method) do
    {
      :__block__,
      [],
      for {action, can_be_singular, http_method} <-
            Enum.zip([@default_actions, @can_be_singular, actions_method]),
          bang <- [:safe, :bang],
          action in actions,
          not singular or can_be_singular do
        action_function_name = build_function_name(action, bang)
        http_method = build_function_name(http_method, bang)
        spec = build_spec(singular, action)
        parameters = build_parameters(singular, action)
        args = build_args(singular, action)
        return = build_return(bang)

        quote do
          @spec unquote(action_function_name)(unquote_splicing(spec)) :: unquote(return)
          def(unquote(action_function_name)(unquote_splicing(parameters))) do
            client(opts).unquote(http_method)(unquote_splicing(args))
          end
        end
      end
    }
  end

  defp build_function_name(action, :safe), do: action
  defp build_function_name(action, :bang), do: String.to_atom("#{action}!")

  defp build_spec(singular, action) do
    [
      if not singular and action in ~w(show update delete)a do
        quote(do: id :: term())
      end,
      if action in ~w(create update)a do
        quote(do: body :: Restlax.Resource.action_body())
      end,
      quote(do: opts :: Restlax.Resource.action_options())
    ]
    |> Enum.reject(&is_nil/1)
  end

  defp build_parameters(singular, action) do
    [
      if not singular and action in ~w(show update delete)a do
        quote(do: id)
      end,
      if action in ~w(create update)a do
        quote(do: body)
      end,
      quote(do: opts \\ [])
    ]
    |> Enum.reject(&is_nil/1)
  end

  defp build_args(singular, action) do
    [
      if not singular and action in ~w(show update delete)a do
        quote(do: path_for(id, opts))
      else
        quote(do: path_for(nil, opts))
      end,
      if action in ~w(create update)a do
        quote(do: body)
      end,
      quote(do: Restlax.Resource.handle_options(opts))
    ]
    |> Enum.reject(&is_nil/1)
  end

  defp build_return(:bang) do
    quote do
      Tesla.Env.t() | no_return()
    end
  end

  defp build_return(:safe) do
    quote do
      Tesla.Env.result()
    end
  end
end
