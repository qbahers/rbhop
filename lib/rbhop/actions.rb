module Rbhop
  module Actions
    class << self
      attr_accessor :operators, :methods
    end
  end

  Actions.operators = {}
  Actions.methods = {}

  # Commands to tell Rbhop what the operators and methods are

  def self.declare_operators(task_name, *op_list)
    op_list.map do |op| 
      Actions.operators[op] = 
        Rbhop::module_eval(task_name.capitalize).method(op.to_sym)
    end
    Actions.operators
  end

  def self.declare_methods(task_name, *method_list)
    Actions.methods[task_name] = method_list.map do|m| 
      Rbhop::module_eval(task_name.capitalize).method(m.to_sym)
    end
    Actions.methods[task_name]
  end
end
