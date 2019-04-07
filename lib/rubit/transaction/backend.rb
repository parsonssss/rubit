require "digest"
require "rubit/serialize"
require "rubit/utils"
require "rubit/db"
require "rubit/core_ext"
require "rubit/transaction"

module Rubit
    module TransactionBackend
        include RubitDb
        include Serialize
        include Utils::Common
        include Mtransaction

        extend self

        using CoreExt


        def unutxo(address,transactions = [])
            spent_utxo_output = Hash.new
            unspent_utxo_output = Array.new
            transactions.each do |transaction|
                caculate(transaction,address,spent_utxo_output,unspent_utxo_output)
            end

            all_block_hash.reverse.map{|hash| fetch_block_with_hash(hash)}.map(&:deserialize).each do |block|
                block.transactions.each do |transaction|
                    caculate(transaction,address,spent_utxo_output,unspent_utxo_output)

                end

            end

            return unspent_utxo_output

        end

        def caculate(transaction, address, spent_utxo_output = {}, unspent_utxo_output = [])

            unless transaction.is_coinbase?
                transaction.vins.each do |vin|
                    if vin.unlock_with_true_addr?(address)
                        if spent_utxo_output.key?(vin.txid)
                            spent_utxo_output[vin.txid] << vin.out_index
                        else
                            spent_utxo_output[vin.txid] = [vin.out_index]
                        end

                    end
                end
            end

            transaction.vouts.each_with_index do |vout, oindex|
                if vout.unlock_with_true_addr?(address)
                    is_spent = false

                    if spent_utxo_output[transaction.txid].nil?
                        utxo = Utxo.new(transaction.txid, oindex, vout)
                        unspent_utxo_output << utxo
                    elsif spent_utxo_output[transaction.txid].include?(oindex)
                        is_spent = true
                        unless is_spent
                            utxo = Utxo.new(transaction.txid, oindex, vout)
                            unspent_utxo_output << utxo
                        end
                    end
                end
            end

            return spent_utxo_output,unspent_utxo_output

        end

    end
end
