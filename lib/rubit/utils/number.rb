module Rubit
    module Utils
        module Number
            include Logger

            extend self

            def big_endian_encode(input)
                raise ArgumentError.new("Input can not be negative number : #{input}") if input < 0
                if input == 0
                    ''.b
                else
                    big_endian_encode(input / 256) + (input % 256).chr
                end
            end

            def big_endian_decode(input)
                begin
                    result = input.each_byte.inject(0) {|sum,each| sum * 256 + each}
                rescue 
                    error "Worng Hex Number"
                else
                    result
                end
            end


        end
    end
end
