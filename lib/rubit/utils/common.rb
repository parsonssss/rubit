require "rubit/const"
require "time"

module Rubit
    module Utils
        module Common
            def is_db_exist?
                File.exist?(Const::DB_FILE)
            end

            def timestamp_in_now
                Time.now.to_i
            end
        end
    end
end
