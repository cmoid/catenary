defmodule Catenary.Live.UnshownExplorer do
  require Logger
  use Phoenix.LiveComponent

  @impl true
  def update(%{which: which, clump_id: clump_id, hidden_us: hidden} = assigns, socket) do
    {:ok, assign(socket, Map.merge(assigns, %{card: extract(which, hidden, clump_id)}))}
  end

  @impl true
  def render(%{card: :none} = assigns), do: Catenary.GeneriCard.no_data_card(assigns)

  def render(%{card: :error} = assigns), do: Catenary.GeneriCard.error_card(assigns)

  def render(assigns) do
    ~L"""
     <div id="unshownexplore-wrap" class="col-span-2 overflow-y-auto max-h-screen m-2 p-x-2">
      <h1 class="text=center">Unshown Explorer</h1>
      <hr/>
      <%= for {type, entries, estring} <- @card do %>
          <h3 class="text-slate-600 dark:text-slate-300"><button phx-click="shown-set" value="<%= estring %>">∅</button>&nbsp;&nbsp;<%= type %></h3>
        <div class="grid grid-cols-5 my-2">
        <%= entries %>
        </div>
      <% end %>
     </div>
    """
  end

  defp extract(:all, hidden, clump_id) do
    shown = Catenary.Preferences.get(:shown) |> Map.get(clump_id, MapSet.new())

    Baobab.all_entries(clump_id)
    |> MapSet.new()
    |> MapSet.difference(shown)
    |> MapSet.to_list()
    |> group_entries(hidden)
  end

  defp extract(_, _, _), do: :none

  defp group_entries(entries, hidden) do
    entries
    |> Enum.group_by(fn {_, l, _} -> QuaggaDef.base_log(l) end)
    |> Map.to_list()
    |> Enum.reject(fn {l, _} ->
      case QuaggaDef.log_def(l) do
        %{name: n} -> MapSet.member?(hidden, n)
        _ -> false
      end
    end)
    |> prettify([])
    |> Enum.sort(:asc)
  end

  defp prettify([], acc), do: acc

  defp prettify([{k, v} | rest], acc),
    do:
      prettify(rest, [
        {Catenary.pretty_log_name(k), icon_entries(v), Catenary.index_list_to_string(v)} | acc
      ])

  defp icon_entries(entries) do
    entries
    |> Enum.reduce("", fn e, a ->
      a <> "<div>" <> Catenary.entry_icon_link(e, 4) <> "</div>"
    end)
    |> Phoenix.HTML.raw()
  end
end
