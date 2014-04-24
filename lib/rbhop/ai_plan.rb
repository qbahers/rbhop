############################################################
# Commands to tell Rbhop what the operators and methods are

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

def ai_plan(state, tasks, verbose=0)
  if verbose > 0
    puts "** ai_plan, verbose = #{verbose}: **"
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
      solution = seek_plan(newstate, tasks.drop(1), plan + [task1], depth + 1, verbose)
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
        solution = seek_plan(state, subtasks + tasks.drop(1), plan, depth + 1, verbose)
        return solution unless solution == false
      end
    end
  end

  puts "depth #{depth} returns failure" if verbose > 2
  false
end

