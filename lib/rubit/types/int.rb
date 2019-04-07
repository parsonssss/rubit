module Rubit
    module Types
class Int
    @size = 8

    class << self
        def max
            (2 ** @size/2 - 1)
        end

        def min
            -(max) - 1
        end

    end

    attr_reader :value

    def initialize(value)
        @value = value
        raise "value must between #{self.class.min} and #{self.class.max}" unless self.vaild?
    end

    def vaild?
        @value <= self.class.max && @value >= self.class.min
    end


end





class Int64 < Int
    @size = 64
end

class Int256 < Int
    @size = 256
end

    end
end
