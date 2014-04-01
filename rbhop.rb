############################################################
## States and goals

class State
  # A state is just a collection of variable bindings.
  attr_accessor :name

  def initialize(name)
    self.name = name
  end
end

class Goal
  # A goal is just a collection of variable bindings.
  attr_accessor :name

  def initialize(name)
    self.name = name
  end
end

### print_state and print_goal are identical except for the name

def print_state(state)
  if state != false
    state.instance_variables.map do |var|
      puts "var :#{var}"
      puts "#{state.name}.#{var} = #{state.instance_variable_get(var)}"
    end
  else
    puts "false"
  end
end

############################################################
## Commands to tell Pyhop what the operators and methods are

operators = []
methods = []

def declare_operators(op_list)
  operators = op_list
  return operators
end

def declare_methods(task_name, method_list)
  methods = method_list
  return methods
end

############################################################
## The actual planner

def rbhop(state, tasks, verbose=0, operators, methods)
  result = seek_plan(state, tasks, [], 0, verbose, operators, methods)
  if verbose > 0
    puts "** rbhop, verbose = #{verbose}: **"
    puts "state = #{state.name}"
    puts "tasks = #{tasks}"
    puts "** result = #{result}"
  end
  result
end

def seek_plan(state, tasks, plan, depth, verbose=0, operators, methods)

  if verbose > 1 then puts "depth #{depth} tasks #{tasks}" end

  if tasks == []
    if verbose > 2
      puts "depth #{depth} returns plan #{plan}"
      return plan
    end
  end

  task1 = tasks[0]
  puts "task1: #{task1}"
  if operators.has_key? task1[0]
    puts "Hey"
    if verbose > 2 then puts "depth #{depth} action #{task1}" end
    puts "operators: #{operators}"
    operator = operators[task1[0]]
    puts "operator: #{operator}"
    newstate = operator.call(state, *task1.drop(1))
    puts "newstate: #{newstate}"

    if verbose > 2
      puts "depth #{depth} new state: "
      print_state(newstate)
    end

    if newstate
      puts "Yo!"
      solution = seek_plan(newstate, tasks.drop(1), plan << task1, depth + 1, verbose, operators, methods)
      unless solution == false then return solution end
    end
  end

  if methods.include? task1[0]
    puts "Hey Hey"
    if verbose > 2 then puts "depth #{depth} method instance #{task1}" end
    relevant = methods.drop(1)
    puts "relevant: #{relevant}"
    relevant.each do |method|
      puts "task1.drop(1): #{task1.drop(1)}"
      #spat operator
      subtasks = method.call(state, *task1.drop(1))
      # ...
      if verbose > 2 then puts "depth #{depth} new tasks: #{subtasks}" end

      unless subtasks == false
        puts "subtasks: #{subtasks}"
        puts "Hej Hej: #{tasks.drop(1)}"
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
  puts "state call_taxi avant: #{state.loc}"
  state.loc["taxi"] = x
  puts "state call_taxi apres: #{state.loc}"
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

operators = {"walk" => method(:walk), "call_taxi" => method(:call_taxi), 
             "ride_taxi" => method(:ride_taxi), "pay_driver" => method(:pay_driver)}
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

state1 = State.new("state1")

state1.loc = {"me" => "home"}
state1.cash = {"me" => 20}
state1.owe = {"me" => 0}
state1.dist = {"home" => {"park" => 8}, "park" => {"home" => 8}}

puts "
********************************************************************************
Call pyhop.pyhop(state1,[('travel','me','home','park')]) with different verbosity levels
********************************************************************************
"

#puts "- If verbose=0 (the default), Pyhop returns the solution but prints nothing."
#rbhop(state1, [], verbose=3, operators)

#puts "- If verbose=1, Pyhop prints the problem and solution, and returns the solution:"
#rbhop(state1,[['travel', :me, :home, :park]], verbose=1, operators)

#puts "- If verbose=2, ...:"
#rbhop(state1,[['travel', :me, :home, :park]], verbose=2, operators)

puts "- If verbose=3, ..."
rbhop(state1,[['travel', "me", "home", "park"]], verbose=3, operators, methods)

