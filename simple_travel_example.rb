require_relative 'rbhop'

############################################################
## The "travel from home to the park" example

def taxi_rate(dist)
  1.5 + 0.5 * dist
end

def walk(state, a, x, y)
  if state.loc[a] == x
    state.loc[a] = y
    return state
  else
    false
  end
end

def call_taxi(state, a, x)
  state.loc["taxi"] = x
  state
end

def ride_taxi(state, a, x, y)
  if state.loc["taxi"] == x and state.loc[a] == x
    state.loc["taxi"] = y
    state.loc[a] = y
    state.owe[a] = taxi_rate(state.dist[x][y])
    return state
  else
    false
  end
end

def pay_driver(state, a)
  if state.cash[a] >= state.owe[a]
    state.cash[a] = state.cash[a] - state.owe[a]
    state.owe[a] = 0
    return state
  else
    false
  end
end

declare_operators("walk", "call_taxi", "ride_taxi", "pay_driver")



def travel_by_foot(state, a, x, y)
  if state.dist[x][y] <= 2
    return [['walk', a, x, y]]
  end
  false
end

def travel_by_taxi(state, a, x, y)
  if state.cash[a] >= taxi_rate(state.dist[x][y])
    return [['call_taxi',a,x], ['ride_taxi',a,x,y], ['pay_driver',a]]
  end
  false
end

declare_methods('travel', "travel_by_foot", "travel_by_taxi")

class State
  attr_accessor :loc, :cash, :owe, :dist
end

state = State.new
state.name = "state1"
state.loc = {"me" => "home"}
state.cash = {"me" => 20}
state.owe = {"me" => 0}
state.dist = {"home" => {"park" => 8}, "park" => {"home" => 8}}

puts "
********************************************************************************
Call rbhop.rbhop(state1,[('travel','me','home','park')]) with different verbosity levels
********************************************************************************
"

puts "", "- If verbose=0 (the default), Rbhop returns the solution but prints nothing."
rbhop(state, [['travel', "me", "home", "park"]])

puts "", "- If verbose=1, Rbhop prints the problem and solution, and returns the solution:"
rbhop(state, [["travel", "me", "home", "park"]], verbose=1)

puts "", "- If verbose=2, Rbhop also prints a note at each recursive call:"
rbhop(state, [['travel', "me", "home", "park"]], verbose=2)

puts "", "- If verbose=3, Rbhop also prints the intermediate states:"
rbhop(state, [['travel', "me", "home", "park"]], verbose=3)

