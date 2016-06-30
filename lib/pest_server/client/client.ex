defmodule PestServer.Client do
  use GenServer

  # Client

  def start_link(pid, id) do
    GenServer.start_link(__MODULE__, pid, name: name(id))
  end

  def kill(id, reason) do
    GenServer.stop(name(id), reason)
  end

  def message(id, message) do
    GenServer.cast(name(id), {:compressed_log, message})
  end

  def logged(id) do
    GenServer.call(name(id), :logged_in)
  end

  # Server (callbacks)
  @timeout 300_000

  def init(pid) do
    Process.send_after(self(), :logged_out, @timeout)
    send(pid, Application.get_env(:pest_server, :auth_host)<>"/auth")
    {:ok, {pid, false}}
  end

  def handle_call(:logged_in, _from, {pid, _logged_in}) do
    {:reply, :ok, {pid, true}}
  end

  def handle_cast({:compressed_log, _message}, state = {_pid, false}) do
    {:noreply, state}
  end

  def handle_cast({:compressed_log, message}, state = {_pid, true}) do
    kafka_message = :zlib.gunzip(message)
    #produce correct json to send
    KafkaEx.produce(Application.get_env(:pest_server, :topic), 0, kafka_message)
    {:noreply, state}
  end

  def handle_info(:logged_out, state = {_pid, false}) do
    {:stop, :shutdown, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp name(id) do
    {:via, :gproc, {:n, :l, {:ws, id}}}
  end
end