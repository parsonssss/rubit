require "digest"

module Rubit
    module Pow
            def cal_hash(difficulty="00")
                nonce = 0
                loop do
                    hash = deal_with_nonce(nonce)
                    if hash.start_with?(difficulty)
                        return nonce,hash
                    else
                        nonce += 1
                    end
                end

            end

            def deal_with_nonce(nonce)
                content = self.instance_variables.reject {|v| v == :@transactions}.map {|x| self.instance_variable_get x}.join
                sha = Digest::SHA256.new
                sha.update(nonce.to_s + content)
                sha.hexdigest
            end

            def set_block_hash
                _nonce,_hash = cal_hash
                self.instance_variable_set(:@nonce,_nonce)
                self.instance_variable_set(:@hash,_hash)
            end

            def hash_transactions
                sha = Digest::SHA256.new

                tx_hashes = self.transactions.map {|t| t.txid}.join
                sha.update(tx_hashes)
                self.instance_variable_set(:@transactions_hash,sha.hexdigest)

            end
    end
end
