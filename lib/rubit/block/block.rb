require "rubit/types"
require "rubit/utils/logger"
require "rubit/block/pow"
require "rubit/serialize"
require "time"
require "yaml"


module Rubit
    module RubBlock

        class Block
            include Rubit::Serialize
            include Types
            include Pow

            attr_reader :hash,:height,:parent_block_hash,:transactions,:transactions_hash

            def initialize(height,parent_block_hash,transactions)
                @height = height
                @timestamp = Time.now.to_i
                @parent_block_hash = parent_block_hash
                @transactions = [].tap{|x| transactions.each {|y| x << y}}

                hash_transactions
                set_block_hash
            end

        end

    end
end
