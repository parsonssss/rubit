require "rubit/serialize"
require "rubit/utils"

module Rubit
    module Mtransaction

        Input = Struct.new(:txid, :out_index, :scriptsig) do
            def unlock_with_true_addr?(address)
                self.scriptsig == address
            end
        end

        Output = Struct.new(:value,:scriptpubkey) do
            def unlock_with_true_addr?(address)
                self.scriptpubkey == address
            end
        end

        Utxo = Struct.new(:txid, :out_index, :output)


        class Transaction

            include Serialize
            include Utils::Common

            attr_reader :vins, :vouts, :txid

            def initialize(tx_inputs,tx_outputs)
                @vins = [].tap {|x|  tx_inputs.each {|y| x << y }}
                @vouts = [].tap {|x| tx_outputs.each {|y| x << y }}
            end

            def set_txid
                bytes = serialize(self)
                sha = Digest::SHA256.new
                sha.update(timestamp_in_now.to_s + bytes)
                txid = sha.hexdigest
                self.instance_variable_set(:@txid,txid)
            end

            def is_coinbase?
                self.vins.first.txid == "0"*32 && self.vins.first.out_index == -1
            end


        end
    end
end
