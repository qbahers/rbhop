############################################################
# States and goals

class State
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def deep_clone
    Marshal.load(Marshal.dump(self))
  end
end

class Goal
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def deep_clone
    Marshal.load(Marshal.dump(self))
  end
end

# print_state and print_goal are identical except for the name

def print_state(state, indent=4)
  if state != false
    state.instance_variables.map do |var|
      indent.times { print " " }
      puts "#{var} = #{state.instance_variable_get(var)}"
    end
  else
    puts "false"
  end
end

def print_goal(state, indent=4)
  if goal != false
    goal.instance_variables.map do |var|
      indent.times { print " " }
      puts "#{var} = #{goal.instance_variable_get(var)}"
    end
  else
    puts "false"
  end
end

############################################################
# Commands to tell Pyhop what the operators and methods are

module Task
  class << self
    attr_accessor :operators, :methods
  end
end

Task.operators = {}
Task.methods = {}

def declare_operators(*op_list)
  op_list.map { |op| Task.operators[op] = method(op.to_sym) }
  Task.operators
end

def declare_methods(task_name, *method_list)
  Task.methods[task_name] = method_list.map { |m| method(m.to_sym) }
  Task.methods[task_name]
end

############################################################
# The actual planner

def rbhop(state, tasks, verbose=0)
  if verbose > 0
    puts "** rbhop, verbose = #{verbose}: **"
    puts "state = #{state.name}"
    puts "tasks = #{tasks}"
  end
  result = seek_plan(state, tasks, [], 0, verbose)
  puts "** result = #{result}" if verbose > 0
  result
end

def seek_plan(state, tasks, plan, depth, verbose=0)
  puts "depth #{depth} tasks #{tasks}" if verbose > 1

  if tasks == []
    puts "depth #{depth} returns plan #{plan}" if verbose > 2
    return plan
  end

  task1 = tasks[0]

  if Task.operators.key? task1[0]
    puts "depth #{depth} action #{task1}" if verbose > 2
    operator = Task.operators[task1[0]]
    newstate = operator.call(state.deep_clone, *task1.drop(1))

    if verbose > 2
      puts "depth #{depth} new state: "
      print_state(newstate)
    end

    if newstate
      solution = seek_plan(newstate, tasks.drop(1), plan << task1, depth + 1, verbose)
      return solution unless solution == false
    end
  end

  if Task.methods.key? task1[0]
    puts "depth #{depth} method instance #{task1}" if verbose > 2
    relevant = Task.methods[task1[0]]
    relevant.each do |method|
      subtasks = method.call(state, *task1.drop(1))
      puts "depth #{depth} new tasks: #{subtasks}" if verbose > 2

      unless subtasks == false
        # TODO: it should be something like "subtasks << tasks.drop(1)" 
        # instead of "subtasks" maybe
        solution = seek_plan(state, subtasks, plan, depth + 1, verbose)
        return solution unless solution == false
      end
    end
  end

  puts "depth #{depth} returns failure" if verbose > 2
  false
end

