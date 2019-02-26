# defmodule Presentator.Scene.Test do
#   use Scenic.Scene
#   alias Scenic.Graph

#   import Scenic.Primitives
#   import Scenic.Components

#   @config Application.get_env(:presentator, :viewport)
#   {x_size, y_size} = @config[:size]
#   @x_size x_size
#   @y_size y_size
#   @rgb_blue {109, 177, 236}
#   @rgb_green {53, 162, 116}

#   @rect1_length 1000
#   @rect1_height 500
#   @rect1_x_loc 20
#   @rect1_y_loc 20

#   @rect2_length 400
#   @rect2_height 400

#   @rect2_x_loc @rect1_x_loc + @rect1_length / 2 - @rect2_length / 2
#   @rect2_y_loc @rect1_y_loc + @rect1_height / 2 - @rect2_height / 2

#   def init(_, _) do
#     Graph.build()
#     |> rect({@x_size, @y_size}, fill: {:linear, {0, 0, 0, @y_size, @rgb_blue, @rgb_green}})
#     |> rrect({@rect1_length, @rect1_height, 20}, fill: :grey, translate: {@rect1_x_loc, @rect1_y_loc})
#     |> rrect({@rect2_length, @rect2_height, 20}, fill: :black, translate: {@rect2_x_loc, @rect2_y_loc})
#     |> push_graph()
#     {:ok, nil}
#   end
# end
