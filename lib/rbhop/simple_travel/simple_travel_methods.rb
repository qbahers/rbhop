# Simple Travel methods

require_relative "../actions"

module Rbhop
  module Travel
    def self.travel_by_foot(state, a, x, y)
      if state.dist[x][y] <= 2
        return [["walk", a, x, y]]
      end
      false
    end

    def self.travel_by_taxi(state, a, x, y)
      if state.cash[a] >= taxi_rate(state.dist[x][y])
        return [["call_taxi",a,x], ["ride_taxi",a,x,y], ["pay_driver",a]]
      end
      false
    end
  end

  declare_methods("travel", "travel_by_foot", "travel_by_taxi")
end
