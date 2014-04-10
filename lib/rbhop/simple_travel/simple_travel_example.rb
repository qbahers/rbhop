=begin
# The "travel from home to the park" example

require_relative "simple_travel_operators"
require_relative "simple_travel_methods"

class StateTravel < State
  attr_accessor :loc, :cash, :owe, :dist
end

state = StateTravel.new("state1")
state.loc  = { "me" => "home" }
state.cash = { "me" => 20 }
state.owe  = { "me" => 0 }
state.dist = { "home" => { "park" => 8 }, "park" => { "home" => 8 } }

puts "
********************************************************************************
Call rbhop.rbhop(state1,[('travel','me','home','park')]) with different verbosity levels
********************************************************************************
"

puts "", "- If verbose=0 (the default), Rbhop returns the solution but prints nothing."
rbhop(state, [["travel", "me", "home", "park"]])

puts "", "- If verbose=1, Rbhop prints the problem and solution, and returns the solution:"
rbhop(state, [["travel", "me", "home", "park"]], verbose=1)

puts "", "- If verbose=2, Rbhop also prints a note at each recursive call:"
rbhop(state, [["travel", "me", "home", "park"]], verbose=2)

puts "", "- If verbose=3, Rbhop also prints the intermediate states:"
rbhop(state, [["travel", "me", "home", "park"]], verbose=3)
=end

