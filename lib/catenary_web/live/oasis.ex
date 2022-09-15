defmodule Catenary.Live.OasisBox do
  use Phoenix.LiveComponent
  @impl true
  def update(assigns, socket) do
    {:ok,
     assign(socket,
       aliasing: assigns.aliasing,
       reffing: assigns.reffing,
       nodes: assigns.watering,
       iconset: assigns.iconset,
       connected: Enum.map(assigns.connections, &id_mapper/1)
     )}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="font-mono text-xs">
      <%= for {recent, index}  <- Enum.with_index(@nodes) do %>
        <div class="my-1 p-1 <%= case rem(index, 2)  do
        0 ->  "bg-emerald-200 dark:bg-cyan-700"
        1 -> "bg-emerald-400 dark:bg-sky-700"
      end %>"><img class="m-1 float-right align-middle" src="<%= Catenary.identicon(elem(recent.id, 0), @iconset, 2)%>">
        <p><%= recent["name"] %> (<%= Catenary.linked_author(elem(recent.id, 0)) %>)
        <%= if recent.id in @connected do %>
          ⥀
        <% else %>
        <button phx-click="connect" phx-disable-with="↯" value="<%= Catenary.index_to_string(recent.id) %>">⇆</button>
        <% end %>
        </p>

        </div>
      <% end %>
        <p class="text-center"><%= if @reffing == :not_running, do: "※", else: "𝍂" %>&nbsp;<%= if @aliasing == :not_running, do: "⍱", else: "⍲" %></p>
    </div>
    """
  end

  defp id_mapper({_, %{id: id}}), do: id
  defp id_mapper({_, _}), do: ""
end
