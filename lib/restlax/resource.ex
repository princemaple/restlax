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

  @type action_body() :: map() | keyword() | Tesla.Multipart.t()
  @type action_options() :: [Tesla.option() | {:client, module()}]

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

  defp build_action_functions(singular, actions, actions_method) do
    {
      :__block__,
      [],
      for {action, can_be_singular, method} <-
            Enum.zip([@default_actions, @can_be_singular, actions_method]),
          action in actions,
          not singular or can_be_singular do
        spec = build_spec(singular, action)
        parameters = build_parameters(singular, action)
        args = build_args(singular, action)

        quote do
          @spec unquote(action)(unquote_splicing(spec)) :: Tesla.Env.result()
          def unquote(action)(unquote_splicing(parameters)) do
            client(opts).unquote(method)(unquote_splicing(args))
          end
        end
      end
    }
  end

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
      quote(do: opts)
    ]
    |> Enum.reject(&is_nil/1)
  end
end
