defmodule MyXQL do
  def start_link(opts) do
    DBConnection.start_link(MyXQL.Protocol, opts)
  end

  def query(conn, statement, params \\ [], opts \\ [])
      when is_binary(statement) or is_list(statement) do
    case run_query(conn, statement, params, opts) do
      {:ok, _query, [%MyXQL.Result{} = result]} ->
        {:ok, result}

      # TODO: handle multiple results in binary protocol
      {:ok, _query, %MyXQL.Result{} = result} ->
        {:ok, result}

      {:ok, query, results} when is_list(results) ->
        raise ArgumentError,
              "query #{inspect(query)} returned #{length(results)} results. Use MyXQL.query_multi/4 handle multiple results."

      {:error, _} = error ->
        error
    end
  end

  def query!(conn, statement, params \\ [], opts \\ []) do
    case query(conn, statement, params, opts) do
      {:ok, result} -> result
      {:error, exception} -> raise exception
    end
  end

  def query_multi(conn, statement, params \\ [], opts \\ [])
      when is_binary(statement) or is_list(statement) do
    case run_query(conn, statement, params, opts) do
      {:ok, _query, results} when is_list(results) ->
        {:ok, results}

      {:error, _} = error ->
        error
    end
  end

  def query_multi!(conn, statement, params \\ [], opts \\ []) do
    case query_multi(conn, statement, params, opts) do
      {:ok, results} -> results
      {:error, exception} -> raise exception
    end
  end

  defp run_query(conn, statement, params, opts) do
    query_type = Keyword.get(opts, :query_type, :binary)

    query = %MyXQL.Query{
      name: "",
      ref: make_ref(),
      statement: statement,
      type: query_type
    }

    case query_type do
      :text ->
        query = %{query | num_params: 0}
        DBConnection.execute(conn, query, params, opts)

      :binary ->
        DBConnection.prepare_execute(conn, query, params, opts)
    end
  end

  def prepare(conn, name, statement, opts \\ []) do
    query = %MyXQL.Query{name: name, statement: statement, ref: make_ref()}
    DBConnection.prepare(conn, query, opts)
  end

  def prepare_execute(conn, name, statement, params \\ [], opts \\ [])
      when is_binary(statement) do
    query = %MyXQL.Query{name: name, statement: statement, ref: make_ref()}

    case DBConnection.prepare_execute(conn, query, params, opts) do
      {:ok, query, result} ->
        {:ok, query, result}

      {:error, _} = error ->
        error
    end
  end

  defdelegate execute(conn, query, params \\ [], opts \\ []), to: DBConnection

  def close(conn, %MyXQL.Query{} = query, opts \\ []) do
    case DBConnection.close(conn, query, opts) do
      {:ok, _} ->
        :ok

      {:error, _} = error ->
        error
    end
  end

  defdelegate transaction(conn, fun, opts \\ []), to: DBConnection

  defdelegate rollback(conn, reason), to: DBConnection

  def stream(conn, query, params \\ [], opts \\ [])

  def stream(%DBConnection{} = conn, statement, params, opts) when is_binary(statement) do
    query = %MyXQL.Query{name: "", ref: make_ref(), statement: statement}
    stream(conn, query, params, opts)
  end

  def stream(%DBConnection{} = conn, %MyXQL.Query{type: :binary} = query, params, opts) do
    opts = Keyword.put_new(opts, :max_rows, 500)
    DBConnection.prepare_stream(conn, query, params, opts)
  end

  def child_spec(opts) do
    DBConnection.child_spec(MyXQL.Protocol, opts)
  end
end
