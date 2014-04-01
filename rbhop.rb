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

  def deep_clone
    Marshal::load(Marshal.dump(self))
  end
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

$operators = {}
$methods = {}

def declare_operators(*op_list)
  op_list.map { |op| $operators[op] = method(op.to_sym) }
  $operators
end

def declare_methods(task_name, *method_list)
  $methods[task_name] = method_list.map {|m| method(m.to_sym)}
  $methods[task_name]
end

############################################################
## The actual planner

def rbhop(state, tasks, verbose=0)
  if verbose > 0
    puts "** rbhop, verbose = #{verbose}: **"
    puts "state = #{state.name}"
    puts "tasks = #{tasks}"
  end
  result = seek_plan(state, tasks, [], 0, verbose)
  if verbose > 0 then puts "** result = #{result}" end
  result
end

def seek_plan(state, tasks, plan, depth, verbose=0)

  if verbose > 1 then puts "depth #{depth} tasks #{tasks}" end

  if tasks == []
    if verbose > 2 then puts "depth #{depth} returns plan #{plan}" end
    return plan
  end

  task1 = tasks[0]
  if $operators.has_key? task1[0]
    if verbose > 2 then puts "depth #{depth} action #{task1}" end
    operator = $operators[task1[0]]
    newstate = operator.call(state.deep_clone, *task1.drop(1))

    if verbose > 2
      puts "depth #{depth} new state: "
      print_state(newstate)
    end

    if newstate
      solution = seek_plan(newstate, tasks.drop(1), plan << task1, depth + 1, verbose)
      unless solution == false then return solution end
    end
  end

  if $methods.has_key? task1[0]
    if verbose > 2 then puts "depth #{depth} method instance #{task1}" end
    relevant = $methods[task1[0]]
    relevant.each do |method|
      #spat operator
      subtasks = method.call(state, *task1.drop(1))
      # ...
      if verbose > 2 then puts "depth #{depth} new tasks: #{subtasks}" end

      unless subtasks == false
        #TODO: it should be something like "subtasks << tasks.drop(1)" 
        #instead of "subtasks" maybe
        solution = seek_plan(state, subtasks, plan, depth + 1, verbose)

        unless solution == false then return solution end
      end
    end
  end

  if verbose > 2 then puts "depth #{depth} returns failure" end
  false
end

