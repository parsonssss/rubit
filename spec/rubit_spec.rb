lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rubit"
require "pry"


RSpec.describe Rubit do
    before do
        Rubit::Utils::Logger.setup(level: :debug)
    end
    
    let! (:chain) { Rubit::BlockChain::RubitChain.instance}
    let  (:genesis_account) {"parsons"}
    let  (:test_account) {"alobak"}

    it "has a version number" do
        expect(Rubit::VERSION).not_to be nil
    end

    describe ".logger" do

        context "when a logger has been setuped" do it "can debug something" do
                expect(Rubit::Utils::Logger.global_logger.add(::Logger::DEBUG,"This is a debug msg"))
            end

            it "can info something" do
                expect(Rubit::Utils::Logger.global_logger.add(::Logger::INFO,"This is a info msg"))
            end

            it "can error something" do
                expect(Rubit::Utils::Logger.global_logger.add(::Logger::ERROR,"This is a error msg"))
            end
        end
    end

    describe ".serialize" do
        include Rubit::Serialize

        context "with Serilize Module" do
            subject(:test_ojb) {Array.new}
            subject(:test_ojb2) {Array.new.to_yaml}


            it "can serialize Obj with to_yaml" do
                expect(serialize(test_ojb)).to eq(Array.new.to_yaml)
            end

            it "can deserialize Obj with YAML.load" do
                expect(deserialize(test_ojb2)).to eq(YAML.load(test_ojb2))

            end
        end
    end

    describe ".block" do
        context "when a block is being creating" do
            let(:a_err_block) {Rubit::RubBlock::Block.new}

            let(:transaction) {chain.create_test_transaction}
            let(:a_good_block) {Rubit::RubBlock::Block.new("0","0"*32,[transaction])}

            it "must pass height , parent_block_hash and transactions to initialize" do
                expect{a_err_block}.to raise_error(ArgumentError)
                expect{a_good_block}.not_to raise_error(ArgumentError)
            end


            it "has a method to hash all the transactions" do
                expect(a_good_block.respond_to? :hash_transactions).to be true
            end

            it "get a transactions_hash instance variable after :hash_transactions method" do
                expect(a_good_block.transactions_hash).to_not be_nil
            end

            it "will set block hash automatically after hash transactions" do
                expect(a_good_block.hash).to_not be_nil
            end

        end

    end

    describe ".blockchain" do
        include Rubit::Serialize

        context "when a blockchain instance has been created" do
            let (:genesis_block) {deserialize(chain.fetch_block_with_hash(chain.current_block_hash))}

            it "will auto create a genesis block or load from db file(now is create a new alwalys for rspec)" do
                expect(chain.all_block_hash.length).to eq(1)
            end

            context "with the genesis block input" do

                it "has txid : 0*32" do
                    expect(genesis_block.transactions.first.vins.first.txid).to eq("0"*32)
                end

                it "has output index : -1" do
                    expect(genesis_block.transactions.first.vins.first.out_index).to eq(-1)
                end

                it "has scriptsig : genesis" do
                    expect(genesis_block.transactions.first.vins.first.scriptsig).to eq("Genesis")
                end

            end


            context "with the genesis block output" do
                it "has a value : 100" do
                    expect(genesis_block.transactions.first.vouts.first.value).to eq(100)
                end

                it "has a scriptpubkey" do
                    expect(genesis_block.transactions.first.vouts.first.scriptpubkey).to eq("parsons")
                end
            end

            context "with the blockchain block instance" do
                subject (:new_transaction) {chain.create_transaction(genesis_account,test_account,50)}

                it "can generate a new block with transactions" do
                    expect(chain.respond_to? :create_block_with_transactions).to be true
                end

                it "can get spentable utxo of a account with find_spendable_utxo method" do
                    expect(chain.respond_to? :find_spendable_utxo).to be true
                    expect(chain.find_spendable_utxo(genesis_account,1000).first).to eq(100)
                    expect(chain.find_spendable_utxo(genesis_account,100).first).to eq(100)
                    expect(chain.find_spendable_utxo(genesis_account,1).first).to eq(100)
                end



                it "can get balance of a account with get_balance method" do
                    expect(chain.respond_to? :get_balance).to be true
                    expect(chain.get_balance(genesis_account)).to eq(100)
                    expect(chain.get_balance(test_account)).to eq(0)
                end

                it "can create a transaction with create_transaction(from,to,amount)" do
                    expect(new_transaction).to be_an_instance_of(Rubit::Mtransaction::Transaction)
                    expect(new_transaction.vins.length).to_not eq(0)
                    expect(new_transaction.vouts.length).to_not eq(0)
                end

            end




        end

    end

    describe ".transaction" do
        describe ".input" do
            subject(:input) {Rubit::Mtransaction::Input.new("txid","output_index","scriptsig")}

            it "has a txid " do
                expect(input.txid).to eq("txid")
            end

            it "has a output_index " do
                expect(input.out_index).to eq("output_index")
            end

            it "has a scriptsig" do
                expect(input.scriptsig).to eq("scriptsig")
            end

        end

        describe ".output" do
            subject(:output) {Rubit::Mtransaction::Output.new("value","scriptpubkey")}

            it "has a value" do
                expect(output.value).to eq("value")
            end

            it "has a scriptpubkey" do
                expect(output.scriptpubkey).to eq("scriptpubkey")
            end
        end

        describe ".utxo" do
            subject(:utxo) {Rubit::Mtransaction::Utxo.new("txid","index","a_output")}

            it "has a txid" do
                expect(utxo.txid).to eq("txid")
            end

            it "has a output index" do
                expect(utxo.out_index).to eq("index")
            end

            it "has a output" do
                expect(utxo.output).to eq("a_output")
            end
        end

        describe ".transaction" do
            subject(:transaction) {chain.create_test_transaction}
            using Rubit::CoreExt

            context "with a transaction" do
                it "has a input" do
                    expect(transaction.vins).to_not be_nil
                end

                it "has a output" do
                    expect(transaction.vouts).to_not be_nil
                end

                it "has a set txid method which can set txid after all transactions have been added" do
                    expect(transaction.respond_to? :set_txid).to be true
                end
            end

            context "when a transaction has been done" do
                it "someone who in the scriptpubkey will get his coin" do
                    expect(Rubit::TransactionBackend.unutxo("parsons").all? {|x|x.output.scriptpubkey == "parsons"}).to be true
                    expect(Rubit::TransactionBackend.unutxo("parsons").reduce(0,&:collect_coin)).to eql(100)
                end
            end


            context "when a output has been used" do
                it "sender's coin will be transaction to receiver as well" do
                    chain.create_block_with_transactions([transaction])
                    expect(Rubit::TransactionBackend.unutxo("parsons").reduce(0,&:collect_coin)).to eql(0)
                    expect(Rubit::TransactionBackend.unutxo("alobak").reduce(0,&:collect_coin)).to eql(100)
                end

            end
        end

    end




end

