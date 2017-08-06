# defmodule FutureFinderTest do
#   use ExUnit.Case
#   test "process setup" do
#     game_map =
#       %{"sites"=>[%{"id"=>4},%{"id"=>1},%{"id"=>3},%{"id"=>6},%{"id"=>5},%{"id"=>0},%{"id"=>7},%{"id"=>2},
#                   %{"id"=>8},%{"id"=>9},%{"id"=>10},%{"id"=>11},%{"id"=>12},%{"id"=>13},%{"id"=>14}],
#         "rivers"=>[%{"source"=>3,"target"=>4},%{"source"=>0,"target"=>1},%{"source"=>2,"target"=>3},
#                    %{"source"=>1,"target"=>3},%{"source"=>5,"target"=>6},%{"source"=>4,"target"=>5},
#                    %{"source"=>3,"target"=>5},%{"source"=>6,"target"=>7},%{"source"=>5,"target"=>7},
#                    %{"source"=>1,"target"=>7},%{"source"=>0,"target"=>7},%{"source"=>1,"target"=>2},
#                    %{"source"=>8,"target"=>4},%{"source"=>9,"target"=>10},%{"source"=>11,"target"=>8},
#                    %{"source"=>10,"target"=>8},%{"source"=>12,"target"=>13},%{"source"=>4,"target"=>12},
#                    %{"source"=>8,"target"=>12},%{"source"=>13,"target"=>14},%{"source"=>12,"target"=>14},
#                    %{"source"=>10,"target"=>14},%{"source"=>9,"target"=>14},%{"source"=>10,"target"=>11}],
#         "mines"=>[1,5,13]}
#     setup_message = {:setup, 0, 2, game_map}
#     game = DataStructure.process(setup_message) |> IO.inspect
#   end
# end