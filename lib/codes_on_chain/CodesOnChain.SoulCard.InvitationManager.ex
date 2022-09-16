defmodule CodesOnChain.SoulCard.InvitationManager do
  @moduledoc """
    manager Invitation
    authority by ethereum signature, save a key value pair in K-V Table
  """
  alias Components.{KVHandler, Verifier, ModuleHandler, MsgHandler}

  def get_module_doc(), do: @moduledoc

  def gen_invitation(addr, msg, signature) do
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- MsgHandler.time_valid?(msg) do
      # generate invitation link and insert it into database.
      payload =  MsgHandler.rand_msg(:str)
      KVHandler.put(addr, payload, ModuleHandler.get_module_name(__MODULE__))
      {:ok, payload}
    else
      error ->
        {:error, inspect(error)}
    end
  end

  @spec check_invitation(String.t(), String.t()) :: boolean
  def check_invitation(addr, invitation) do
    addr
    |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
    |> Kernel.==(invitation)
  end

end