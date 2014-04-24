module Rbhop
  class Goal
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def deep_clone
      Marshal.load(Marshal.dump(self))
    end

    def print(indent=4)
      if self != false
        self.instance_variables.map do |var|
          indent.times { print " " }
          puts "#{var} = #{self.instance_variable_get(var)}"
        end
      else
        puts "false"
      end
    end
  end
end
