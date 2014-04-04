require_relative "simple_travel_operators"
require_relative "simple_travel_methods"

class StateTravel < State
  attr_accessor :loc, :cash, :owe, :dist

  def initialize(cash, dist)
    @name = "state1"
    @loc  = { "me" => "home" }
    @cash = { "me" => cash.to_i }
    @owe  = { "me" => 0 }
    @dist = { "home" => { "park" => dist.to_i }, "park" => { "home" => dist.to_i } }
  end
end
