require "logger"

module Rubit
    module Utils
        module Logger
            class << self
                attr_reader :global_logger

                def setup(level:)
                    @global_logger = ::Logger.new(STDERR, level: level)
                end

            end
    
            protected

            def debug(msg)
                add(::Logger::DEBUG,msg)
            end

            def info(msg)
                add(::Logger::INFO,msg)
            end

            def error(msg)
                add(::Logger::ERROR,msg)
            end

            private

            def add(severity, msg = nil, who = self.class.inspect)
                Logger.global_logger&.add(severity, msg, who)
            end


        end

    end
end
