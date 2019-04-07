require "singleton"
require "forwardable"
require "rubit/block"
require "rubit/db"
require "rubit/serialize"
require "rubit/utils/common"
require "rubit/transaction"
require "tempfile"

require "pry"

module Rubit
    module BlockChain
        class NotEnoughMoneyError < StandardError;end
        class MoneyError < StandardError;end

        class RubitChain
            extend Forwardable
            include Singleton
            include Rubit::Utils::Logger
            include Rubit::Utils::Common
            include Serialize
            include RubitDb
            include Mtransaction
            include Rubit::TransactionBackend

            attr_accessor :current_block_hash

            def initialize
                Rubit::Utils::Logger.setup(level: :debug)
                generate_genesis_block
            end

            def create_test_transaction
                current_block = deserialize(fetch_block_with_hash(@current_block_hash))
                input = [].tap {|x| x << Input.new(current_block.transactions.first.txid,0,"parsons")}
                output = [].tap {|x| x << Output.new(100,"alobak")}
                Transaction.new(input,output).tap {|x| x.set_txid}
            end

            def create_transaction(from,to,amount = 0)
                 unless amount.is_a?(Numeric) && amount > 0
                      return MoneyError.new
                 end

                 balance, the_spendable_utxo = find_spendable_utxo(from,amount)
                 if balance < amount
                     return NotEnoughMoneyError.new
                 end

                 transaction_inputs = []

                 the_spendable_utxo.each_pair do |txid,index|
                     Rubit::Mtransaction::Input.new(txid,index,from).tap {|input| transaction_inputs.push input}
                 end

                 transactions_outputs = []

                 #send to receiver
                 Rubit::Mtransaction::Output.new(amount, to).tap {|output| transactions_outputs.push output if output.value > 0}
                 #change if excess
                 Rubit::Mtransaction::Output.new(balance - amount, from).tap {|output| transactions_outputs.push output if output.value > 0}

                 Rubit::Mtransaction::Transaction.new(transaction_inputs,transactions_outputs).tap {|t| t.set_txid}

            end


                def generate_block(height,parent_block_hash,transactions)
                    newblock = Rubit::RubBlock::Block.new(height,parent_block_hash,transactions)
                    add_block_to_chain(newblock)

                    info "Generate a new block with height -> #{newblock.height} and  hash -> #{newblock.hash}"

                    newblock
                end

                def create_block_with_transactions(transactions)
                    unless transactions.first.kind_of? StandardError
                        current_block = deserialize(fetch_block_with_hash(@current_block_hash))
                        generate_block(current_block.height+1,current_block.hash,transactions)
                    else
                        case transactions.first
                        when NotEnoughMoneyError.new
                            error "you have not enough money to pay for"
                        when MoneyError.new
                            error "transfer money is invaild, check it!"
                        end
                    end
                end

                def create_first_transaction
                    input = [].tap {|x| x << Input.new("0"*32,-1,"Genesis")}
                    output = [].tap {|x| x << Output.new(100,"parsons")}
                    Transaction.new(input,output).tap {|x| x.set_txid}
                end

                # 测试使用,正式使用时记得删除注释以及tf
                def generate_genesis_block
                   if is_db_exist?
                       Rubit::RubitDb.setup
                       @current_block_hash = fetch_last_hash
                   else
                       #tf = Tempfile.new("blockdb")
                       coinbase_transaction = create_first_transaction
                       transactions = [coinbase_transaction]
                       Rubit::RubitDb.setup()
                       generate_block(0,GENESIS_PARENT_BLOCK_HASH,transactions)
                   end
                end

                def add_block_to_chain(block)
                    data = serialize(block)
                    insert_a_block_into_db(block.hash,data)
                    @current_block_hash = block.hash
                end

                def find_spendable_utxo(account,amount,txs = [])
                    balance = 0
                    utxos = {}

                    spendable_utxo = Rubit::TransactionBackend.unutxo(account,txs)

                    spendable_utxo.each do |utxo|
                        if balance >= amount
                            break
                        end

                        balance += utxo.output.value
                        utxos[utxo.txid] = utxo.out_index
                    end

                    return balance,utxos

                end

            def get_balance(account)
                balance = 0

                spendable_utxo = Rubit::TransactionBackend.unutxo(account)
                spendable_utxo.each do |utxo|
                    balance += utxo.output.value
                end

                balance
            end


        end
    end
end
