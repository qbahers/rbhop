# Simple Travel operators

require_relative "../ai_plan"

module Rbhop
  module Travel
    def self.taxi_rate(dist)
      1.5 + 0.5 * dist
    end

    def self.walk(state, a, x, y)
      if state.loc[a] == x
        state.loc[a] = y
        state
      else
        false
      end
    end

    def self.call_taxi(state, a, x)
      state.loc["taxi"] = x
      state
    end

    def self.ride_taxi(state, a, x, y)
      if state.loc["taxi"] == x && state.loc[a] == x
        state.loc["taxi"] = y
        state.loc[a] = y
        state.owe[a] = taxi_rate(state.dist[x][y])
        state
      else
        false
      end
    end

    def self.pay_driver(state, a)
      if state.cash[a] >= state.owe[a]
        state.cash[a] = state.cash[a] - state.owe[a]
        state.owe[a] = 0
        state
      else
        false
      end
    end
  end
end

declare_operators("travel", "walk", "call_taxi", "ride_taxi", "pay_driver")

