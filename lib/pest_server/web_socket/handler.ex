defmodule PestServer.WebSocket.Handler do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @timeout 300_000 # terminate if no activity for five minute

  # Called on websocket connection initialization.
  def websocket_init(_type, req, _opts) do
    id = UUID.uuid4()
    {:ok, pid} = Supervisor.start_child(
                            Client.Supervisor,
                            [self(), id])
    Process.link(pid)
    {:ok, req, id, @timeout}
  end

  # Handle 'ping' messages from the client - reply
  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  # Handle other messages from the client - do not reply
  def websocket_handle({:binary, message}, req, id) do
    PestServer.Client.message(name(id), message)
    {:ok, req, id}
  end

  # Format and forward elixir messages to client
  def websocket_info(message, req, state) do
    {:reply, {:text, message}, req, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, id) do
    PestServer.Client.kill(id, :shutdown)
    :ok
  end

  defp name(id) do
    {:via, :gproc, {:n, :l, {:ws, id}}}
  end
end