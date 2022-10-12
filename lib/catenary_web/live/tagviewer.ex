defmodule Catenary.Live.TagViewer do
  require Logger
  use Phoenix.LiveComponent

  @impl true
  def update(%{tag: which} = assigns, socket) do
    {:ok, assign(socket, Map.merge(assigns, %{card: extract(which)}))}
  end

  @impl true
  def render(%{card: :none} = assigns) do
    ~L"""
      <div class="min-w-full font-sans row-span-full">
        <h1>No data just yet</h1>
      </div>
    """
  end

  def render(%{card: :error} = assigns) do
    ~L"""
      <div class="min-w-full font-sans row-span-full">
        <h1>Unrenderable card</h1>
      </div>
    """
  end

  def render(assigns) do
    ~L"""
     <div id="tagview-wrap" class="col-span-2 overflow-y-auto max-h-screen m-2 p-x-2">
      <div class="min-w-full font-sans row-span-full">
        <h1 class="text=center">Entries tagged with "<%= @tag %>"</h1>
        <hr/>
        <%= for {type, entries} <- @card do %>
          <h3  class="pt-5 text-slate-600 dark:text-slate-300"><%= type %></h3>
        <div class="grid grid-cols-5 my-2">
        <%= entries %>
      </div>
    <% end %>
      <div class="mt-10 text-center"><button phx-click="tag-explorer">⧟ ### ⧟</button>
      </div>
    </div>
    """
  end

  defp extract(tag) do
    tag
    |> from_dets(:tags)
    |> Enum.group_by(fn {_, {_, l, _}} -> QuaggaDef.base_log(l) end)
    |> Map.to_list()
    |> prettify([])
    |> Enum.sort(:asc)
  end

  defp prettify([], acc), do: acc

  defp prettify([{k, v} | rest], acc),
    do: prettify(rest, [{Catenary.pretty_log_name(k), icon_entries(v)} | acc])

  defp icon_entries(entries) do
    entries
    |> Enum.reduce("", fn {_d, e}, a ->
      a <> "<div>" <> Catenary.entry_icon_link(e, 4) <> "</div>"
    end)
    |> Phoenix.HTML.raw()
  end

  defp from_dets(entry, table) do
    Catenary.dets_open(table)

    val =
      case :dets.lookup(table, {"", entry}) do
        [] -> []
        [{_, v}] -> v
      end

    Catenary.dets_close(table)
    val
  end
end
