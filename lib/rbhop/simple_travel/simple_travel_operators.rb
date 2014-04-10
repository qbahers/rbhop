# Simple Travel operators

require_relative "../ai_plan"

def taxi_rate(dist)
  1.5 + 0.5 * dist
end

def walk(state, a, x, y)
  if state.loc[a] == x
    state.loc[a] = y
    state
  else
    false
  end
end

def call_taxi(state, a, x)
  state.loc["taxi"] = x
  state
end

def ride_taxi(state, a, x, y)
  if state.loc["taxi"] == x && state.loc[a] == x
    state.loc["taxi"] = y
    state.loc[a] = y
    state.owe[a] = taxi_rate(state.dist[x][y])
    state
  else
    false
  end
end

def pay_driver(state, a)
  if state.cash[a] >= state.owe[a]
    state.cash[a] = state.cash[a] - state.owe[a]
    state.owe[a] = 0
    state
  else
    false
  end
end

declare_operators("walk", "call_taxi", "ride_taxi", "pay_driver")

