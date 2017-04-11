defmodule Gold do
  use Application

  require Logger

  alias Gold.Transaction

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    opts = [strategy: :one_for_one, name: Gold.Supervisor]
    Supervisor.start_link([], opts)
  end

  ##
  # Client-side
  ##
  @doc """
  Returns basic info about wallet and connection
  """
  def getinfo(name) do
    case call(name, {:getinfo, []}) do
      {:ok, info} -> 
        {:ok, info}
      otherwise -> 
        otherwise
    end
  end

  @doc """
  Returns basic info about wallet and connection, raising an exeption on failure.
  """
  def getinfo!(name) do
    {:ok, info} = getinfo(name)
    info
  end

  @doc """
  Returns wallet's total available balance.
  """
  def getbalance(name), do: getbalance(name, "")

  @doc """
  Returns wallet's total available balance, raising an exception on failure.
  """
  def getbalance!(name), do: getbalance!(name, "")

  @doc """
  Returns wallet's total available balance.
  """
  def getbalance(name, account), do: getbalance(name, account, 1)

  @doc """
  Returns wallet's total available balance, raising an exception on failure.
  """
  def getbalance!(name, account), do: getbalance!(name, account, 1)

  @doc """
  Returns wallet's total available balance.
  """
  def getbalance(name, account, confirmations), do: getbalance(name, account, confirmations, false)

  @doc """
  Returns wallet's total available balance, raising an exception on failure.
  """
  def getbalance!(name, account, confirmations), do: getbalance!(name, account, confirmations, false)

  @doc """
  Returns wallet's total available balance.
  """
  def getbalance(name, account, confirmations, watchonly) do
    case call(name, {:getbalance, [account, confirmations, watchonly]}) do
      {:ok, balance} -> 
        {:ok, btc_to_decimal(balance)}
      otherwise -> 
        otherwise
    end        
  end

  @doc """
  Returns server's total available balance, raising an exception on failure.
  """
  def getbalance!(name, account, confirmations, watchonly) do
    {:ok, balance} = getbalance(name, account, confirmations, watchonly)
    balance
  end

  @doc """
  Returns a new bitcoin address for receiving payments.
  """
  def getnewaddress(name), do: getnewaddress(name, "")

  @doc """
  Returns a new bitcoin address for receiving payments, raising an exception on failure.
  """
  def getnewaddress!(name), do: getnewaddress!(name, "")

  @doc """
  Returns a new bitcoin address for receiving payments.
  """
  def getnewaddress(name, account), do: call(name, {:getnewaddress, [account]})

  @doc """
  Returns a new bitcoin address for receiving payments, raising an exception on failure.
  """
  def getnewaddress!(name, account) do
    {:ok, address} = getnewaddress(name, account)
    address
  end

  @doc """
  Returns the account associated with the given address.
  """
  def getaccount(name, address), do: call(name, {:getaccount, [address]})

  @doc """
  Returns the account associated with the given address, raising an exception on failure.
  """
  def getaccount!(name, address) do
    {:ok, account} = getaccount(name, address)
    account
  end

  @doc """
  Returns most recent transactions in wallet.
  """
  def listtransactions(name), do: listtransactions(name, "*")

  @doc """
  Returns most recent transactions in wallet, raising an exception on failure.
  """
  def listtransactions!(name), do: listtransactions!(name, "*")

  @doc """
  Returns most recent transactions in wallet.
  """
  def listtransactions(name, account), do: listtransactions(name, account, 10)

  @doc """
  Returns most recent transactions in wallet, raising an exception on failure.
  """
  def listtransactions!(name, account), do: listtransactions!(name, account, 10)

  @doc """
  Returns most recent transactions in wallet.
  """
  def listtransactions(name, account, limit), do: listtransactions(name, account, limit, 0)

  @doc """
  Returns most recent transactions in wallet, raising an exception on failure.
  """
  def listtransactions!(name, account, limit), do: listtransactions!(name, account, limit, 0)

  @doc """
  Returns most recent transactions in wallet.
  """
  def listtransactions(name, account, limit, offset), do: listtransactions(name, account, limit, offset, false)

  @doc """
  Returns most recent transactions in wallet, raising an exception on failure.
  """
  def listtransactions!(name, account, limit, offset), do: listtransactions!(name, account, limit, offset, false)

  @doc """
  Returns most recent transactions in wallet.
  """
  def listtransactions(name, account, limit, offset, watchonly) do
    case call(name, {:listtransactions, [account, limit, offset, watchonly]}) do
      {:ok, transactions} ->
        {:ok, Enum.map(transactions, &Transaction.from_json/1)}
      otherwise ->
        otherwise
    end        
  end

  @doc """
  Returns most recent transactions in wallet, raising an exception on failure.
  """
  def listtransactions!(name, account, limit, offset, watchonly) do
    {:ok, transactions} = listtransactions(name, account, limit, offset, watchonly)
    transactions
  end

  @doc """
  Get detailed information about in-wallet transaction.
  """
  def gettransaction(name, txid) do
    case call(name, {:gettransaction, [txid]}) do
      {:ok, transaction} ->
        {:ok, Transaction.from_json transaction}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Get detailed information about in-wallet transaction, raising an exception on
  failure.
  """
  def gettransaction!(name, txid) do
    {:ok, tx} = gettransaction(name, txid)
    tx
  end

  @doc """
  Send an amount to a given address.
  """
  def sendtoaddress(name, address, %Decimal{} = amount) do
    call(name, {:sendtoaddress, [address, amount]})
  end

  @doc """
  Send an amount to a given address, raising an exception on failure.
  """
  def sendtoaddress!(name, address, %Decimal{} = amount) do
    {:ok, txid} = sendtoaddress(name, address, amount)
    txid
  end

  @doc """
  Add an address or pubkey script to the wallet without the associated private key.
  """
  def importaddress(name, address), do: importaddress(name, address, "")

  @doc """
  Add an address or pubkey script to the wallet without the associated private key,
  raising an exception on failure.
  """
  def importaddress!(name, address), do: importaddress!(name, address, "")

  @doc """
  Add an address or pubkey script to the wallet without the associated private key.
  """
  def importaddress(name, address, account), do: importaddress(name, address, account, true)

  @doc """
  Add an address or pubkey script to the wallet without the associated private key,
  raising an exception on failure.
  """
  def importaddress!(name, address, account), do: importaddress!(name, address, account, true)

  @doc """
  Add an address or pubkey script to the wallet without the associated private key.
  """
  def importaddress(name, address, account, rescan) do
    call(name, {:importaddress, [address, account, rescan]})
  end

  @doc """
  Add an address or pubkey script to the wallet without the associated private key,
  raising an exception on failure.
  """
  def importaddress!(name, address, account, rescan) do
    {:ok, _} = importaddress(name, address, account, rescan)
    :ok
  end

  @doc """
  Mine block immediately. Blocks are mined before RPC call returns.
  """
  def generate(name, amount) do
    call(name, {:generate, [amount]})
  end

  @doc """
  Mine block immediately. Blocks are mined before RPC call returns. Raises an
  exception on failure.
  """
  def generate!(name, amount) do
    {:ok, result} = generate(name, amount)
    result
  end

  @doc """
  Call generic RPC command
  """
  def call(name, {method, params}) when is_atom(method) do
    case load_config(name) do
      :undefined ->
        {:error, {:invalid_configuration, name}}
      config ->
        handle_rpc_request(method, [], config)
          |> handle_call
    end
  end

  defp handle_call({:reply, reply, _config}) do
    reply
  end

  ##
  # Internal functions
  ##
  defp handle_rpc_request(method, params, config) when is_atom(method) do
    %{hostname: hostname, port: port, user: user, password: password} = config

    Logger.debug "Bitcoin RPC request for method: #{method}, params: #{inspect params}"

    params = PoisonedDecimal.poison_params(params)

    command = %{"jsonrpc": "2.0",
                "method": to_string(method),
                "params": params,
                "id": 1}

    headers = ["Authorization": "Basic " <> Base.encode64(user <> ":" <> password)]

    options = [timeout: 30000, recv_timeout: 20000]

    case HTTPoison.post("http://" <> hostname <> ":" <> to_string(port) <> "/", Poison.encode!(command), headers, options) do
      {:ok, %{status_code: 200, body: body}} -> 
        case Poison.decode!(body) do
          %{"error" => nil, "result" => result} -> {:reply, {:ok, result}, config}
          %{"error" => error} -> {:reply, {:error, error}, config}
        end
      {:ok, %{status_code: code, body: error}} ->
        {:reply, handle_error(code, error), config}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug "Bitcoin RPC HTTP error: #{reason}"
        {:reply, {:error, status: :connection_closed, error: reason}, config}
      otherwise -> 
        Logger.error "Bitcoin RPC unexpected response: #{inspect otherwise}"
        {:reply, otherwise, config}
    end
  end

  @statuses %{401 => :forbidden, 404 => :notfound, 500 => :internal_server_error}

  defp handle_error(status_code, error) do
    status = @statuses[status_code]
    Logger.debug "Bitcoin RPC error status #{status}: #{error}"
    %{"error" => %{"message" => message}} = Poison.decode!(error)
    {:error, %{status: status, error: message}}
  end

  @doc """
  Converts a float BTC amount to an Decimal.
  """
  def btc_to_decimal(btc) when is_float(btc) do
    satoshi_per_btc = :math.pow(10, 8)

    # Convert the bitcoins to integer to avoid any precision loss
    satoshi = round(btc * satoshi_per_btc)

    # Now construct a decimal
    %Decimal{sign: if(satoshi < 0, do: -1, else: 1), coef: abs(satoshi), exp: -8}
  end
  def btc_to_decimal(nil), do: nil

  defp load_config(name) do
    case :application.get_env(:gold, name) do
      {:ok, config} -> Enum.into(config, %{})
      :undefined -> :undefined
    end
  end

end
