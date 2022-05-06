defmodule UserDb do

  def init_user_db() do
    ServerDb.init_db(:user_db)
  end

end
