require_relative "simple_travel_operators"
require_relative "simple_travel_methods"

class StateTravel < State
  attr_accessor :loc, :cash, :owe, :dist

  def initialize(dist, cash)
    @name = "state1"
    @loc  = { "me" => "home" }
    @cash = { "me" => cash }
    @owe  = { "me" => 0 }
    @dist = { "home" => { "park" => dist }, "park" => { "home" => dist } }
  end
end
