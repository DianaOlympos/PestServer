defmodule PestServer.Client do
  use GenServer
  alias PestServer.UserDetails

  # Client

  def start_link(pid, id) do
    GenServer.start_link(__MODULE__, {pid, id}, name: name(id))
  end

  def kill(id, reason) do
    GenServer.stop(name(id), reason)
  end

  def message(id, message) do
    GenServer.cast(name(id), {:compressed_log, message})
  end

  def logged(id, user_details) do
    GenServer.call(name(id), {:logged_in, user_details})
  end

  # Server (callbacks)
  @timeout 300_000

  def init({pid, id}) do
    Process.send_after(self(), :logged_out, @timeout)
    query = URI.encode_query(%{"id" => id})
    send(pid, Application.get_env(:pest_server, :auth_host)<>"/auth?"<>query)
    user = %UserDetails{}
    {:ok, {pid, false, user}}
  end

  def handle_call({:logged_in, user_details}, _from, {pid, _logged_in, _details}) do
    {:reply, :ok, {pid, true, user_details}}
  end

  def handle_cast({:compressed_log, _message}, state = {_pid, false, _details}) do
    {:noreply, state}
  end

  def handle_cast({:compressed_log, message}, state = {_pid, true, details}) do
    kafka_message = :zlib.gunzip(message)

    #produce correct json to send
    KafkaEx.produce(Application.get_env(:pest_server, :topic), 0, kafka_message)
    {:noreply, state}
  end

  def handle_info(:logged_out, state = {_pid, false, _details}) do
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