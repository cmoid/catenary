defmodule Catenary.MenuBar do
  use Desktop.Menu
  @impl true
  def mount(menu) do
    menu = assign(menu, iconset: :png)
    {:ok, menu}
  end

  @impl true
  def handle_event(command, menu) do
    nm =
      case command do
        <<"quit">> ->
          Desktop.Window.quit()

        <<"png">> ->
          Phoenix.PubSub.local_broadcast(Catenary.PubSub, "ui", %{icons: :png})
          menu

        <<"svg">> ->
          Phoenix.PubSub.local_broadcast(Catenary.PubSub, "ui", %{icons: :svg})
          menu

        <<"dashboard">> ->
          Phoenix.PubSub.local_broadcast(Catenary.PubSub, "ui", %{view: :dashboard})
          menu

        <<"journal">> ->
          Phoenix.PubSub.local_broadcast(Catenary.PubSub, "ui", %{entry: :journal})
          menu

        <<"oasis">> ->
          Phoenix.PubSub.local_broadcast(Catenary.PubSub, "ui", %{entry: :oasis})
          menu

        <<"test">> ->
          Phoenix.PubSub.local_broadcast(Catenary.PubSub, "ui", %{entry: :test})
          menu
      end

    {:noreply, nm}
  end

  @impl true
  def handle_info(stuff, menu) do
    IO.inspect({:unhandled_menu, stuff})
    {:noreply, menu}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <menubar>
      <menu label="File">
          <item onclick="dashboard">Open dashboard</item>
          <item onclick="quit">Quit</item>
      </menu>
      <menu label="Explore">
        <item onclick="journal">Journals</item>
        <item onclick="oasis">Oases</item>
        <item onclick="test">Test posts</item>
      </menu>
      <menu label="Icons">
        <item onclick="png">Blocky</item>
        <item onclick="svg">Curvy</item>
      </menu>
    </menubar>
    """
  end
end
