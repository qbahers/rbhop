############################################################
## States and goals

class State
  attr_accessor :name

  def deep_clone
    Marshal::load(Marshal.dump(self))
  end
end

class Goal
  attr_accessor :name
end

### print_state and print_goal are identical except for the name

def print_state(state, indent=4)
  if state != false
    state.instance_variables.map do |var|
      indent.times {print ' '}
      puts "#{var} = #{state.instance_variable_get(var)}"
    end
  else
    puts "false"
  end
end

def print_goal(state, indent=4)
  if goal != false
    goal.instance_variables.map do |var|
      indent.times {print ' '}
      puts "#{var} = #{goal.instance_variable_get(var)}"
    end
  else
    puts "false"
  end
end

############################################################
## Commands to tell Pyhop what the operators and methods are

operators = {}
methods = []

def declare_operators(*op_list, operators)
  op_list.map do |op|
    operators[op] = method(op.to_sym)
  end
end

############################################################
## The actual planner

def rbhop(state, tasks, verbose=0, operators, methods)
  if verbose > 0
    puts "** rbhop, verbose = #{verbose}: **"
    puts "state = #{state.name}"
    puts "tasks = #{tasks}"
  end
  result = seek_plan(state, tasks, [], 0, verbose, operators, methods)
  if verbose > 0 then puts "** result = #{result}" end
  result
end

def seek_plan(state, tasks, plan, depth, verbose=0, operators, methods)

  if verbose > 1 then puts "depth #{depth} tasks #{tasks}" end

  if tasks == []
    if verbose > 2 then puts "depth #{depth} returns plan #{plan}" end
    return plan
  end

  task1 = tasks[0]
  if operators.has_key? task1[0]
    if verbose > 2 then puts "depth #{depth} action #{task1}" end
    operator = operators[task1[0]]
    newstate = operator.call(state.deep_clone, *task1.drop(1))

    if verbose > 2
      puts "depth #{depth} new state: "
      print_state(newstate)
    end

    if newstate
      solution = seek_plan(newstate, tasks.drop(1), plan << task1, depth + 1, verbose, operators, methods)
      unless solution == false then return solution end
    end
  end

  if methods.include? task1[0]
    if verbose > 2 then puts "depth #{depth} method instance #{task1}" end
    relevant = methods.drop(1)
    relevant.each do |method|
      #spat operator
      subtasks = method.call(state, *task1.drop(1))
      # ...
      if verbose > 2 then puts "depth #{depth} new tasks: #{subtasks}" end

      unless subtasks == false
        solution = seek_plan(state, subtasks, plan, depth + 1, verbose, operators, methods)

        unless solution == false then return solution end
      end
    end
  end

  if verbose > 2 then puts "depth #{depth} returns failure" end
  false
end

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

declare_operators("walk", "call_taxi", "ride_taxi", "pay_driver", operators)
puts ""
#print_operators()



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

methods = ["travel", method(:travel_by_foot), method(:travel_by_taxi)]
puts ""
#rbhop.print_methods()

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
rbhop(state, [['travel', "me", "home", "park"]], operators, methods)

puts "", "- If verbose=1, Rbhop prints the problem and solution, and returns the solution:"
rbhop(state, [["travel", "me", "home", "park"]], verbose=1, operators, methods)

puts "", "- If verbose=2, Rbhop also prints a note at each recursive call:"
rbhop(state, [['travel', "me", "home", "park"]], verbose=2, operators, methods)

puts "", "- If verbose=3, Rbhop also prints the intermediate states:"
rbhop(state, [['travel', "me", "home", "park"]], verbose=3, operators, methods)

