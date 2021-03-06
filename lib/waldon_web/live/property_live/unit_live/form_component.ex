defmodule WaldonWeb.PropertyLive.UnitFormComponent do
  use WaldonWeb, :live_component

  alias Waldon.Properties

  @impl true
  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset,
    "#",
    id: "unit-form",
    phx_target: @myself,
    phx_change: "validate",
    phx_submit: "save" %>

    <div>
      <h3 class="text-lg font-medium leading-6 text-gray-900"><%= @title %></h3>
      <p class="mt-2 text-sm text-gray-500">
        Save Unit
      </p>
    </div>


    <div class="grid grid-cols-1 mt-5 gap-y-6 gap-x-4">

      <div>
        <%= label f, :name, class: "block text-sm font-medium text-gray-700" %>
        <div class="relative mt-1">
          <%= text_input f, :name, class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md"  %>
        </div>
        <%= error_tag f, :name %>
      </div>


      <div class="pt-5">
      <div class="flex items-center justify-end">
        <button phx-click="close" phx-target="#modal" type="button" class="px-6 py-1 font-medium text-gray-700 bg-white border border-gray-300 rounded shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
          Cancel
        </button>
        <%= submit "Save", phx_disable_with: "Saving...", class: "btn ml-4" %>
      </div>

    </div>
    </form>
    """
  end

  @impl true
  def update(%{unit: unit} = assigns, socket) do
    changeset = Properties.change_unit(unit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"unit" => unit_params}, socket) do
    changeset =
      socket.assigns.unit
      |> Properties.change_unit(unit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"unit" => unit_params}, socket) do
    save_unit(socket, socket.assigns.action, unit_params)
  end

  defp save_unit(socket, :edit_unit, unit_params) do
    case Properties.update_unit(socket.assigns.unit, unit_params) do
      {:ok, _property} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_unit(socket, :new, unit_params) do
    case Properties.create_unit(socket.assigns.property, unit_params) do
      {:ok, _property} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
