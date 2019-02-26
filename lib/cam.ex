defmodule Cam do
  def frame do
    try do
      if Node.ping(:"presentor_fw@presentor_fw.local") == :pong do
        :rpc.call(:"presentor_fw@presentor_fw.local", Picam.Camera, :start_link, [])
        :rpc.call(:"presentor_fw@presentor_fw.local", Picam, :set_size, [648, 480])
        image = :rpc.call(:"presentor_fw@presentor_fw.local", Picam, :next_frame, [])
        {image, 640, 480}
      end
    catch
      _, _ -> nil
    end
  end
end
