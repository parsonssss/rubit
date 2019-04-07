module Rubit
    module Types
class Uint
    @size = 0
    attr_reader :size


    class << self
        def min
            0
        end

        def max
            2 ** @size - 1
        end

        def vaild?(value)
            value >= min && value <= max
        end

    end

    def initialize(value)
        raise "Invaild value,value must between #{self.class.min} and #{self.class.max}" unless self.class.vaild?(value)
        @value = value
    end

    def to_i
        @value.to_i
    end

end

class Uint8 < Uint
    @size = 8
end

class Uint256 < Uint
    @size = 256
end

class Uint32 < Uint
    @size = 32
end

    end
end

