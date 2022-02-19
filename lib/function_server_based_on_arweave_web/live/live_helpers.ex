defmodule FunctionServerBasedOnArweaveWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `FunctionServerBasedOnArweaveWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal FunctionServerBasedOnArweaveWeb.CodeLoaderLive.FormComponent,
        id: @code_loader.id || :new,
        action: @live_action,
        code_loader: @code_loader,
        return_to: Routes.code_loader_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(FunctionServerBasedOnArweaveWeb.ModalComponent, modal_opts)
  end
end
