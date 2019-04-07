require "pstore"

require "rubit/const"

module Rubit
    module RubitDb
          include Const

          class << self
              attr_reader :global_db

              def setup(db_file = nil)
                  db_file ||= Const::DB_FILE
                  @global_db = PStore.new(db_file)
              end

          end

          #测试时注释
          #protected

          def insert_a_block_into_db(hash,block)
              db.transaction do
                  db[hash] = block
                  db[Const::LAST_BLOCK] = hash
                  db.commit
              end
          end

          def fetch_block_with_hash(hash)
              db.transaction(true) do
                  db[hash]
              end
          end

          def fetch_last_hash
              db.transaction(true) do
                  db[Const::LAST_BLOCK]
              end
          end

          def all_block_hash
              db.transaction(true) do
                  db.roots.tap {|x| x.delete_at(1)}
              end
          end

          private

          def db
              RubitDb.global_db
          end



    end
end
