defmodule FwUpload do
  def test do
    upload(
      "192.168.1.131",
      "/home/connor/oss/elixir/presentator/presentor_fw/_build/rpi3_dev/nerves/images/presentor_fw.fw"
    )
  end

  def upload(ip, fwfile) do
    try do
      port = 8989
      stats = File.stat!(fwfile)
      fwsize = stats.size
      Application.ensure_all_started(:ssh)
      user_dir = Path.expand("~/.ssh") |> to_charlist
      connect_opts = [silently_accept_hosts: true, user_dir: user_dir, auth_methods: 'publickey']
      {:ok, connection_ref} = :ssh.connect(to_charlist(ip), port, connect_opts)
      {:ok, channel_id} = :ssh_connection.session_channel(connection_ref, :infinity)

      :success =
        :ssh_connection.subsystem(connection_ref, channel_id, 'nerves_firmware_ssh', :infinity)

      :ok = :ssh_connection.send(connection_ref, channel_id, "fwup:#{fwsize},reboot\n")

      spawn(fn ->
        File.stream!(fwfile, [:bytes], 4096)
        |> Stream.map(fn chunk ->
          :ok = :ssh_connection.send(connection_ref, channel_id, chunk)
        end)
        |> Stream.run()
      end)
    catch
      _, _ -> :ok
    end
  end
end
