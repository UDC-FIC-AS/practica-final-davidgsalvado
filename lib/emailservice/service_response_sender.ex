defmodule ServiceResponseSender do

  def send_response(resp, dir_rec_pid) do
    send(dir_rec_pid, resp)
  end

end
