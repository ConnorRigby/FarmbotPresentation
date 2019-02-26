defmodule Presentator.Scene.Home do
  use Scenic.Scene
  use AMQP
  require Logger

  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components

  @exchange "amq.topic"
  @token System.get_env("FARMBOT_TOKEN")
  @token || Mix.raise("""
  You forgot to export a farmbot token in your env
  """)
  @username "device_6"
  @vhost "szxossex"
  @host "spirited-crow.rmq.cloudamqp.com"

  @arial_black_path Application.app_dir(:presentator, [
                      "priv",
                      "static",
                      "fonts",
                      "OpenSansEmoji.ttf"
                    ])
  @arial_black_hash Scenic.Cache.Hash.file!(@arial_black_path, :sha)

  @config Application.get_env(:presentator, :viewport)
  {x_size, y_size} = @config[:size]
  @x_size x_size
  @y_size y_size

  # Height of three rectangles
  @center_rect_height @y_size / 1.75

  # Heading
  @heading_text_size 60
  @heading_id :heading

  # Location of the heading text after the animation
  @heading_text_y_pos @center_rect_height - @y_size / 2.5

  # Picture slider
  @center_rect_id :center_rect
  @center_rect_length @x_size / 1.75
  @center_rect_height @center_rect_height
  @center_rect_x_pos @x_size / 2 - @center_rect_length / 2
  @center_rect_y_pos @y_size / 2 - @center_rect_height / 2

  @center_rect_pos {@center_rect_x_pos, @center_rect_y_pos}

  @lr_rect_offset 5
  # Location data rect
  @right_rect_id :right_rect
  @right_rect_length @x_size / 5
  @right_rect_height @center_rect_height

  @right_rect_x_pos @center_rect_x_pos + @center_rect_length + @lr_rect_offset
  @right_rect_y_pos @y_size / 2 - @right_rect_height / 2

  @right_rect_pos {@right_rect_x_pos, @right_rect_y_pos}

  @right_rect_text_id :right_rect_title_text

  # Location data rect
  @left_rect_id :left_rect
  @left_rect_length @x_size / 5
  @left_rect_height @center_rect_height

  @left_rect_x_pos @center_rect_x_pos - @left_rect_length - @lr_rect_offset
  @left_rect_y_pos @y_size / 2 - @left_rect_height / 2

  @left_rect_position {@left_rect_x_pos, @left_rect_y_pos}

  @bottom_rect_id :bottom_rect
  @bottom_rect_text_id :log_text
  @bottom_rect_length @right_rect_length + @center_rect_length + @left_rect_length
  @bottom_rect_height 200
  @bottom_rect_x_pos @left_rect_x_pos
  @bottom_rect_y_pos @left_rect_y_pos + @left_rect_height + @lr_rect_offset
  @bottom_rect_position {@bottom_rect_x_pos, @bottom_rect_y_pos}

  # Slides
  Module.register_attribute(__MODULE__, :steps_acc, accumulate: true)
  # Cached images
  Module.register_attribute(__MODULE__, :images, accumulate: true)

  @steps_acc {:update_title, "Who Am I"}
  @steps_acc {:update_title, "What is FarmBot?"}
  @steps_acc :setup_layout

  image = Application.app_dir(:presentator, ["priv", "static", "images", "00farmbot.png"])
  <<_, _, base::binary>> = Path.split(image) |> List.last() |> Path.rootname()
  path_attr_name = String.to_atom(base <> "_path")
  path_attr = image
  path_hash_name = String.to_atom(base <> "_hash")
  path_hash = Scenic.Cache.Hash.file!(path_attr, :sha)

  Module.put_attribute(__MODULE__, path_attr_name, path_attr)
  Module.put_attribute(__MODULE__, path_hash_name, path_hash)

  Module.put_attribute(
    __MODULE__,
    :images,
    {String.to_atom(base), path_attr, path_hash, 400, 400}
  )

  Module.put_attribute(
    __MODULE__,
    :steps_acc,
    {:slide_image_in, String.to_atom(base), "What is FarmBot?", 400, 400}
  )

  @steps_acc {:update_title, "FarmBot is Open Source"}
  @steps_acc {:update_title, "FarmBot 💖 Open Source"}
  @steps_acc :meta_image_capture

  part_one_images =
    Application.app_dir(:presentator, ["priv", "static", "images", "01", "*.png"])
    |> Path.wildcard()

  for image <- part_one_images do
    <<_, _, base::binary>> = Path.split(image) |> List.last() |> Path.rootname()
    path_attr_name = String.to_atom(base <> "_path")
    path_attr = image
    path_hash_name = String.to_atom(base <> "_hash")
    path_hash = Scenic.Cache.Hash.file!(path_attr, :sha)

    Module.put_attribute(__MODULE__, path_attr_name, path_attr)
    Module.put_attribute(__MODULE__, path_hash_name, path_hash)

    Module.put_attribute(
      __MODULE__,
      :images,
      {String.to_atom(base), path_attr, path_hash, 400, 400}
    )

    Module.put_attribute(
      __MODULE__,
      :steps_acc,
      {:slide_image_in, String.to_atom(base), "FarmBot 💖 #{String.upcase(base)}", 400, 400}
    )

    @external_resource path_attr
  end

  @steps_acc {:update_title, "What is Nerves?"}
  @steps_acc {:update_title, "Nerves is Open Source"}
  @steps_acc {:update_title, "Nerves 💖 Open Source"}

  part_two_images =
    Application.app_dir(:presentator, ["priv", "static", "images", "02", "*.png"])
    |> Path.wildcard()

  for image <- part_two_images do
    IO.inspect(image, label: "image")
    <<_, _, base::binary>> = Path.split(image) |> List.last() |> Path.rootname()
    path_attr_name = String.to_atom(base <> "_path")
    path_attr = image
    path_hash_name = String.to_atom(base <> "_hash")
    path_hash = Scenic.Cache.Hash.file!(path_attr, :sha)

    Module.put_attribute(__MODULE__, path_attr_name, path_attr)
    Module.put_attribute(__MODULE__, path_hash_name, path_hash)

    Module.put_attribute(
      __MODULE__,
      :images,
      {String.to_atom(base), path_attr, path_hash, 400, 400}
    )

    Module.put_attribute(
      __MODULE__,
      :steps_acc,
      {:slide_image_in, String.to_atom(base), "Nerves 💖 #{String.upcase(base)}", 400, 400}
    )

    @external_resource path_attr
  end

  @steps_acc {:try_meta_image_gag, "FarmBot 💖 Live Demos"}

  part_three_images =
    Application.app_dir(:presentator, ["priv", "static", "images", "03", "*.png"])
    |> Path.wildcard()

  for image <- part_three_images do
    IO.inspect(image, label: "image")
    <<_, _, base::binary>> = Path.split(image) |> List.last() |> Path.rootname()
    path_attr_name = String.to_atom(base <> "_path")
    path_attr = image
    path_hash_name = String.to_atom(base <> "_hash")
    path_hash = Scenic.Cache.Hash.file!(path_attr, :sha)

    Module.put_attribute(__MODULE__, path_attr_name, path_attr)
    Module.put_attribute(__MODULE__, path_hash_name, path_hash)

    Module.put_attribute(
      __MODULE__,
      :images,
      {String.to_atom(base), path_attr, path_hash, 1000, 1000}
    )

    Module.put_attribute(
      __MODULE__,
      :steps_acc,
      {:slide_image_in, String.to_atom(base), "FarmBot 💖 Live Demos", 1000, 1000}
    )

    @external_resource path_attr
  end

  @steps_acc :start_fw_upload

  part_four_images =
    Application.app_dir(:presentator, ["priv", "static", "images", "04", "*.png"])
    |> Path.wildcard()

  for image <- part_four_images do
    IO.inspect(image, label: "image")
    <<_, _, base::binary>> = Path.split(image) |> List.last() |> Path.rootname()
    path_attr_name = String.to_atom(base <> "_path")
    path_attr = image
    path_hash_name = String.to_atom(base <> "_hash")
    path_hash = Scenic.Cache.Hash.file!(path_attr, :sha)

    Module.put_attribute(__MODULE__, path_attr_name, path_attr)
    Module.put_attribute(__MODULE__, path_hash_name, path_hash)

    Module.put_attribute(
      __MODULE__,
      :images,
      {String.to_atom(base), path_attr, path_hash, 400, 400}
    )

    Module.put_attribute(
      __MODULE__,
      :steps_acc,
      {:slide_image_in, String.to_atom(base), "FarmBot 💖 NervesHub", 400, 400}
    )

    @external_resource path_attr
  end

  @steps_acc {:update_title, "Thanks!"}

  @steps Enum.reverse(@steps_acc)

  # 6db1ec
  @rgb_blue {109, 177, 236}
  # 35a274
  @rgb_green {53, 162, 116}

  @meta_image_id :meta_image_gag
  @fwup_progress_id :fwup_progress

  def terminate(_, _) do
    Process.unregister(__MODULE__)
  end

  def init(_a, _b) do
    Process.register(self(), __MODULE__)
    {:ok, conn} = open_amqp_connection()
    Process.link(conn.pid)
    {:ok, chan} = Channel.open(conn)
    :ok = Basic.qos(chan, global: true)
    route = "bot.device_6.#"
    Queue.declare(chan, "farmbot_demo", auto_delete: true)
    :ok = Queue.bind(chan, "farmbot_demo", @exchange, routing_key: route)

    Scenic.Cache.File.load(@arial_black_path, @arial_black_hash)

    for {_, path_attr, path_hash, _, _} <- @images do
      Scenic.Cache.File.load(path_attr, path_hash)
    end

    graph =
      Graph.build()
      |> rect({@x_size, @y_size}, fill: {:linear, {0, 0, 0, @y_size, @rgb_blue, @rgb_green}})
      |> heading("Functional Farming with Farmbot")
      # Center rectangle
      |> rrect({@center_rect_length, @center_rect_height, 20},
        fill: {0x70, 0x80, 0x90, 0x00},
        translate: @center_rect_pos,
        id: @center_rect_id
      )
      # Right rectangle
      |> rrect({@right_rect_length, @right_rect_height, 20},
        fill: {0x70, 0x80, 0x90, 0x00},
        translate: @right_rect_pos,
        id: @right_rect_id
      )
      # Right rectangle text
      |> text("FarmBot JR Status",
        font: @arial_black_hash,
        font_blur: 2.0,
        text_align: :center,
        fill: {0, 0, 0, 0},
        translate: {@right_rect_x_pos + 126, @right_rect_y_pos + 26},
        id: @right_rect_text_id
      )
      # Right rectangle text blur
      |> text("FarmBot JR Status",
        font: @arial_black_hash,
        text_align: :center,
        fill: {255, 255, 255, 0},
        translate: {@right_rect_x_pos + 125, @right_rect_y_pos + 25},
        id: @right_rect_text_id
      )

      # Left rectangle
      |> rrect({@left_rect_length, @left_rect_height, 20},
        fill: {0x70, 0x80, 0x90, 0x00},
        translate: @left_rect_position,
        id: @left_rect_id
      )

      # bottom rectangle
      |> rrect({@bottom_rect_length, @bottom_rect_height, 20},
        fill: {0x70, 0x80, 0x90, 0x00},
        translate: @bottom_rect_position,
        id: @bottom_rect_id
      )
      # Log message text box
      |> text("",
        font: @arial_black_hash,
        text_align: :left,
        font_blur: 2.0,
        fill: {0, 0, 0, 0},
        translate: {@bottom_rect_x_pos + 101, @bottom_rect_y_pos + @bottom_rect_height / 2 + 1},
        id: @bottom_rect_text_id
      )
      # Log message text box
      |> text("",
        font: @arial_black_hash,
        text_align: :left,
        fill: {255, 255, 255, 0x00},
        translate: {@bottom_rect_x_pos + 100, @bottom_rect_y_pos + @bottom_rect_height / 2},
        id: @bottom_rect_text_id
      )

      # Load all the images offscreen
      |> (fn graph ->
            Enum.reduce(@images, graph, fn {id, _path, hash, x_size, y_size}, graph ->
              # final_x_pos = @center_rect_x_pos + @center_rect_length / 2 - x_size / 2
              final_y_pos = @center_rect_y_pos + @center_rect_height / 2 - y_size / 2

              rect(graph, {x_size, y_size},
                translate: {@x_size, final_y_pos},
                fill: {:image, hash},
                hidden: true,
                id: id
              )
            end)
          end).()
      |> push_graph()

    {:ok,
     %{
       conn: conn,
       chan: chan,
       graph: graph,
       steps: @steps,
       prev: [],
       bot_state: nil,
       animating: false
     }}
  end

  def handle_info(:start_fw_upload, state) do
    fw = Path.join([:code.priv_dir(:presentator), "static", "firmware", "good_farmbot.fw"])
    FwUpload.upload("farmbot.local", fw)
    initial = "|                                    | 0%"

    graph =
      state.graph
      |> text(initial,
        text_align: :center,
        translate:
          {@center_rect_x_pos + @center_rect_length / 2,
           @center_rect_y_pos + @center_rect_height / 2 - 250},
        id: @fwup_progress_id
      )
      |> push_graph()

    {:noreply, %{state | graph: graph}}
  end

  def handle_info({:ssh_cm, _, {:data, 0, 0, "\r|" <> _ = msg}}, state) do
    msg = String.trim(msg)

    graph =
      state.graph
      |> Graph.modify(@fwup_progress_id, fn itm ->
        text(itm, msg)
      end)
      |> push_graph()

    {:noreply, %{state | graph: graph}}
  end

  def handle_info({:ssh_cm, _, {:data, _, _, _}}, state) do
    {:noreply, state}
  end

  def handle_info({:ssh_cm, _, {:closed, _}}, state) do
    send(self(), :animation_complete)
    {:noreply, %{state | animating: true}}
  end

  def handle_info(:meta_image_capture, state) do
    case Cam.frame() do
      {image, x_size, y_size} when is_binary(image) ->
        hash = Scenic.Cache.Hash.binary!(image, :sha)
        Scenic.Cache.put(hash, image)
        final_x_pos = @center_rect_x_pos + @center_rect_length / 2 - x_size / 2
        final_y_pos = @center_rect_y_pos + @center_rect_height / 2 - y_size / 2

        graph =
          state.graph
          |> rect({x_size, y_size},
            translate: {final_x_pos, final_y_pos},
            fill: {:image, hash},
            hidden: true,
            id: @meta_image_id
          )
          |> push_graph()

        {:noreply, %{state | graph: graph}}

      _ ->
        send(self(), :animation_complete)
        send(self(), :skip)
        {:noreply, state}
    end
  end

  def handle_info({:try_meta_image_gag, title}, state) do
    graph =
      state.graph
      |> update_heading(title)
      |> Graph.modify(@meta_image_id, fn itm ->
        update_opts(itm, hidden: false)
      end)
      |> push_graph()

    send(self(), :animation_complete)
    {:noreply, %{state | graph: graph, animating: true}}
  end

  # Handles moving the header from center to the top
  # And fading in the rectangles
  def handle_info(:setup_layout, %{graph: graph} = state) do
    graph =
      graph
      |> Graph.modify(@heading_id, fn %{transforms: %{translate: {cur_x, cur_y}}} = existing ->
        update_opts(existing, translate: {cur_x, cur_y - 1})
      end)
      # Modify the three rects.
      # increase the alpha until they are opaque
      |> Graph.modify(
        fn
          @center_rect_id -> true
          @right_rect_id -> true
          @right_rect_text_id -> true
          @left_rect_id -> true
          @bottom_rect_id -> true
          @bottom_rect_text_id -> true
          _ -> false
        end,
        fn
          %{styles: %{fill: {_, _, _, 250}}} = existing ->
            existing

          %{styles: %{fill: {r, g, b, a}}} = existing ->
            update_opts(existing, fill: {r, g, b, a + 1})
        end
      )
      |> push_graph()

    [%{transforms: %{translate: {_x_pos, y_pos}}} | _] = Graph.get(graph, @heading_id)

    if y_pos >= @heading_text_y_pos do
      Process.send_after(self(), :setup_layout, 3)
      {:noreply, %{state | graph: graph, animating: true}}
    else
      send(self(), :animation_complete)
      send(self(), :skip)
      {:ok, _} = Basic.consume(state.chan, "farmbot_demo", self(), no_ack: true)
      {:noreply, %{state | graph: enable_position_buttons(graph)}}
    end
  end

  def handle_info({:update_title, title}, state) do
    graph =
      state.graph
      |> update_heading(title)
      |> push_graph()

    send(self(), :animation_complete)
    {:noreply, %{state | graph: graph, animating: true}}
  end

  def handle_info({:slide_image_in, id, text, x_size, _y_size} = msg, state) do
    graph =
      state.graph
      |> update_heading(text)
      # Hide all other images
      |> (fn graph ->
            Enum.reduce(@images, graph, fn
              {^id, _, _, _, _}, graph ->
                Graph.modify(graph, id, fn %{transforms: %{translate: {x_pos, y_pos}}} = prim ->
                  update_opts(prim, hidden: false, translate: {x_pos - 15, y_pos})
                end)

              {hide_id, _, _, _, _}, graph ->
                Graph.modify(graph, hide_id, fn prim ->
                  update_opts(prim, hidden: true)
                end)
            end)
          end).()
      |> Graph.modify(@meta_image_id, &update_opts(&1, hidden: true))
      |> push_graph()

    [%{transforms: %{translate: {x_pos, _y_pos}}}] = Graph.get(graph, id)

    final_x_loc = @center_rect_x_pos + @center_rect_length / 2 - x_size / 2

    if x_pos >= final_x_loc do
      Process.send_after(self(), msg, 3)
      {:noreply, %{state | graph: graph, animating: true}}
    else
      send(self(), :animation_complete)
      {:noreply, %{state | graph: graph, animating: true}}
    end
  end

  def handle_info(:animation_complete, state) do
    {:noreply, %{state | animating: false}}
  end

  def handle_info(:skip, %{animating: false, steps: [step | rest]} = state) do
    send(self(), step)
    {:noreply, %{state | steps: rest, prev: [step | state.prev]}}
  end

  def handle_info({:basic_deliver, payload, %{routing_key: "bot.device_6.status"}}, state) do
    bot_state = Jason.decode!(payload)
    %{"location_data" => %{"position" => %{"x" => x, "y" => y, "z" => z}}} = bot_state
    %{"pins" => pins} = bot_state
    graph =
      state.graph
      |> set_farmbot_xyz(x, y, z)
      |> set_farmbot_pins(pins)

    {:noreply, %{state | bot_state: bot_state, graph: graph}}
  end

  def handle_info({:basic_deliver, payload, %{routing_key: "bot.device_6.logs"}}, state) do
    # IO.inspect(payload, label: "LOG")
    %{"message" => message} = Jason.decode!(payload)

    graph =
      state.graph
      |> Graph.modify(@bottom_rect_text_id, fn itm ->
        text(itm, message)
      end)
      |> push_graph()

    {:noreply, %{state | graph: graph}}
  end

  def handle_info({:basic_deliver, _payload, %{routing_key: "bot.device_6.from_clients"}}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, _payload, %{routing_key: "bot.device_6.from_device"}}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, _}, state) do
    send_message(state, "Farmbot JR is now connected to live demo!")
    {:noreply, state}
  end

  def handle_info(step, state) do
    IO.inspect(step, label: "unknown step")
    {:noreply, state}
  end

  def filter_event({:click, :button_elock}, _, state) do
    emergency_lock(state)
    {:stop, state}
  end

  def filter_event({:click, :button_eunlock}, _, state) do
    emergency_unlock(state)
    {:stop, state}
  end

  def filter_event({:click, :button_UP}, _, state) do
    move_rel(state, 50, 0, 0)
    {:stop, state}
  end

  def filter_event({:click, :button_DN}, _, state) do
    move_rel(state, -50, 0, 0)
    {:stop, state}
  end

  def filter_event({:click, :button_LF}, _, state) do
    move_rel(state, 0, -50, 0)
    {:stop, state}
  end

  def filter_event({:click, :button_RT}, _, state) do
    move_rel(state, 0, 50, 0)
    {:stop, state}
  end

  def filter_event({:click, :button_ZUP}, _, state) do
    move_rel(state, 0, 0, 50)
    {:stop, state}
  end

  def filter_event({:click, :button_ZDN}, _, state) do
    move_rel(state, 0, 0, -50)
    {:stop, state}
  end

  def filter_event({:click, :button_HM}, _, state) do
    home(state)
    {:stop, state}
  end

  def filter_event({:value_changed, {:toggle_pin, num}, _}, _, state) do
    toggle_pin(state, num)
    {:stop, state}
  end

  def filter_event(event, _, state) do
    IO.puts("event: #{inspect(event)}")
    {:stop, state}
  end

  def handle_input({:key, {key, :release, _}}, _context, %{animating: true} = state) do
    IO.inspect(key, label: "keypress")
    push_graph(state.graph)
    {:noreply, state}
  end

  def handle_input(
        {:key, {key, :release, _}},
        _context,
        %{animating: false, steps: [step | rest]} = state
      ) do
    IO.inspect(key, label: "keypress")
    send(self(), step)
    {:noreply, %{state | steps: rest, prev: [step | state.prev]}}
  end

  def handle_input(_input, _, state) do
    {:noreply, state}
  end

  def heading(graph, text) do
    graph
    |> Graph.delete(@heading_id)
    |> heading(text, {@x_size / 2, @y_size / 2})
  end

  def heading(graph, text, {x, y} = pos) do
    graph
    |> text(text,
      font: @arial_black_hash,
      font_size: @heading_text_size,
      translate: {x + 1, y + 1},
      text_align: :center,
      fill: :black,
      font_blur: 2.0,
      id: @heading_id
    )
    |> text(text,
      font: @arial_black_hash,
      font_size: @heading_text_size,
      translate: pos,
      text_align: :center,
      id: @heading_id
    )
  end

  def update_heading(graph, text) do
    Graph.modify(graph, @heading_id, fn item ->
      text(item, text)
    end)
  end

  def enable_position_buttons(graph) do
    button_width = 50
    button_height = 50
    x_base = @left_rect_x_pos + @left_rect_length / 2 - button_width / 2 - 35
    y_base = @left_rect_y_pos + @left_rect_y_pos / 2 - button_height / 2 + 100

    graph
    |> button("E-LOCK", [
      id: :button_elock,
      width: @left_rect_length - 50,
      height: 50,
      theme: :danger,
      radius: 20,
      translate: {@left_rect_x_pos + 25, @left_rect_y_pos + 25}
    ]
    )
    |> button("E-UNLOCK ", [
      id: :button_eunlock,
      width: @left_rect_length - 50,
      height: 50,
      theme: :warning,
      radius: 20,
      translate: {@left_rect_x_pos + 25, @left_rect_y_pos + 80}
    ]
    )
    |> button("UP",
      id: :button_UP,
      width: button_width,
      height: button_height,
      theme: :info,
      translate: {x_base, y_base}
    )
    |> button("DN",
      id: :button_DN,
      width: button_width,
      height: button_height,
      theme: :info,
      translate: {x_base, y_base + 55}
    )
    |> button("LF",
      id: :button_LF,
      width: button_width,
      height: button_height,
      theme: :info,
      translate: {x_base - 55, y_base + 55}
    )
    |> button("RT",
      id: :button_RT,
      width: button_width,
      height: button_height,
      theme: :info,
      translate: {x_base + 55, y_base + 55}
    )
    |> button("ZUP",
      id: :button_ZUP,
      width: button_width,
      height: button_height,
      theme: :info,
      translate: {x_base + 55 + 55, y_base}
    )
    |> button("ZDN",
      id: :button_ZDN,
      width: button_width,
      height: button_height,
      theme: :info,
      translate: {x_base + 55 + 55, y_base + 55}
    )
    |> button("HM",
      id: :button_HM,
      width: button_width,
      height: button_height,
      theme: :info,
      translate: {x_base + 55 + 55, y_base + 55 * 2}
    )
    |> text("Test LED", [
      font_blur: 2.0,
      fill: {0, 0, 0},
      text_align: :left,
      translate: {x_base - 86, y_base + 158}
    ])
    |> text("Test LED", [
      text_align: :left,
      translate: {x_base - 85, y_base + 157}
    ])
    |> toggle(false, [
      translate: {x_base, y_base + 150}, 
      theme: :info,
      id: {:toggle_pin, 13}
    ])
    |> text("Lighting", [
      font_blur: 2.0,
      fill: {0, 0, 0},
      text_align: :left,
      translate: {x_base - 86, y_base + 188}
    ])
    |> text("Lighting", [
      text_align: :left,
      translate: {x_base - 85, y_base + 187}
    ])
    |> toggle(false, [
      translate: {x_base, y_base + 180}, 
      theme: :info,
      id: {:toggle_pin, 7}
    ])
    |> text("Water", [
      font_blur: 2.0,
      fill: {0, 0, 0},
      text_align: :left,
      translate: {x_base - 86, y_base + 218}
    ])
    |> text("Water", [
      text_align: :left,
      translate: {x_base - 85, y_base + 217}
    ])
    |> toggle(false, [
      translate: {x_base, y_base + 210}, 
      theme: :info,
      id: {:toggle_pin, 8}
    ])
    |> text("Vacuum", [
      font_blur: 2.0,
      fill: {0, 0, 0},
      text_align: :left,
      translate: {x_base - 86, y_base + 248}
    ])
    |> text("Vacuum", [
      text_align: :left,
      translate: {x_base - 85, y_base + 247}
    ])
    |> toggle(false, [
      translate: {x_base, y_base + 240}, 
      theme: :info,
      id: {:toggle_pin, 9}
    ])
    |> push_graph()
  end

  def set_farmbot_pins(graph, pins) do
    Enum.reduce(pins, graph, fn
      {pin_number, %{"value" => 0}}, graph ->
        IO.inspect(pin_number, label: "PIN_NUMBER(off)")
        Graph.modify(graph, {:toggle_pin, String.to_integer(pin_number)}, &toggle(&1, false))
      {pin_number, %{"value" => 1}}, graph ->
        IO.inspect(pin_number, label: "PIN_NUMBER(on)")
        Graph.modify(graph, {:toggle_pin, String.to_integer(pin_number)}, &toggle(&1, true))
      _, graph -> graph
    end)
    |> push_graph()
  end

  def set_farmbot_xyz(graph, x_pos, y_pos, z_pos) do
    IO.puts("setting xyz = #{x_pos} #{y_pos} #{z_pos}")
    base_x = @right_rect_x_pos + 35
    base_y = @right_rect_y_pos + 25
    y_offset = 35

    graph
    |> Graph.delete(:x_position_text_id)
    |> Graph.delete(:y_position_text_id)
    |> Graph.delete(:z_position_text_id)
    |> text("X position = #{x_pos}",
      font: @arial_black_hash,
      font_blur: 2.0,
      fill: :black,
      translate: {base_x + 1, base_y + y_offset + 1},
      id: :x_position_text_id
    )
    |> text("X position = #{x_pos}",
      font: @arial_black_hash,
      translate: {base_x, base_y + y_offset},
      id: :x_position_text_id
    )
    |> text("Y position = #{y_pos}",
      font: @arial_black_hash,
      font_blur: 2.0,
      fill: :black,
      translate: {base_x + 1, base_y + y_offset * 2 + 1},
      id: :y_position_text_id
    )
    |> text("Y position = #{y_pos}",
      font: @arial_black_hash,
      translate: {base_x, base_y + y_offset * 2},
      id: :y_position_text_id
    )
    |> text("Z position = #{z_pos}",
      font: @arial_black_hash,
      font_blur: 2.0,
      fill: :black,
      translate: {base_x + 1, base_y + y_offset * 3 + 1},
      id: :z_position_text_id
    )
    |> text("Z position = #{z_pos}",
      font: @arial_black_hash,
      translate: {base_x, base_y + y_offset * 3},
      id: :z_position_text_id
    )
    |> push_graph()
  end

  defp move_rel(state, off_x, off_y, off_z) do
    rpc = %{
      kind: :move_relative,
      args: %{x: off_x, y: off_y, z: off_z, speed: 100}
    }

    read_status = %{
      kind: :read_status,
      args: %{}
    }

    payload = %{
      kind: :rpc_request,
      args: %{label: "/shrug"},
      body: [rpc, read_status]
    }

    json = Jason.encode!(payload)
    AMQP.Basic.publish(state.chan, @exchange, "bot.device_6.from_clients", json)
  end

  def home(state) do
    rpc = %{
      kind: :home,
      args: %{axis: :all}
    }

    read_status = %{
      kind: :read_status,
      args: %{}
    }

    payload = %{
      kind: :rpc_request,
      args: %{label: "/shrug"},
      body: [rpc, read_status]
    }

    json = Jason.encode!(payload)
    AMQP.Basic.publish(state.chan, @exchange, "bot.device_6.from_clients", json)
  end

  def send_message(state, message, type \\ :success) do
    rpc = %{
      kind: :send_message,
      args: %{message: message, message_type: type}
    }

    read_status = %{
      kind: :read_status,
      args: %{}
    }

    payload = %{
      kind: :rpc_request,
      args: %{label: "/shrug"},
      body: [rpc, read_status]
    }

    json = Jason.encode!(payload)
    AMQP.Basic.publish(state.chan, @exchange, "bot.device_6.from_clients", json)
  end

  def toggle_pin(state, pin_num) do
    rpc = %{
      kind: :toggle_pin,
      args: %{pin_number: pin_num}
    }

    read_status = %{
      kind: :read_status,
      args: %{}
    }

    payload = %{
      kind: :rpc_request,
      args: %{label: "/shrug"},
      body: [rpc, read_status]
    }

    json = Jason.encode!(payload)
    AMQP.Basic.publish(state.chan, @exchange, "bot.device_6.from_clients", json)
  end

  def emergency_lock(state) do
    rpc = %{
      kind: :emergency_lock,
      args: %{}
    }

    read_status = %{
      kind: :read_status,
      args: %{}
    }

    payload = %{
      kind: :rpc_request,
      args: %{label: "/shrug"},
      body: [rpc, read_status]
    }

    json = Jason.encode!(payload)
    AMQP.Basic.publish(state.chan, @exchange, "bot.device_6.from_clients", json)    
  end

  def emergency_unlock(state) do
    rpc = %{
      kind: :emergency_unlock,
      args: %{}
    }

    read_status = %{
      kind: :read_status,
      args: %{}
    }

    payload = %{
      kind: :rpc_request,
      args: %{label: "/shrug"},
      body: [rpc, read_status]
    }

    json = Jason.encode!(payload)
    AMQP.Basic.publish(state.chan, @exchange, "bot.device_6.from_clients", json)    
  end

  defp open_amqp_connection() do
    Logger.info("Opening new AMQP connection.")

    opts = [
      host: @host,
      username: @username,
      password: @token,
      virtual_host: @vhost
    ]

    AMQP.Connection.open(opts)
  end
end
