require "yaml"

module Rubit
    module CoreExt
        refine(String) do
            def serialize
                self.to_yaml
            end

            def deserialize
                YAML.load(self)
            end
        end

        refine(Integer) do
            def collect_coin(utxo)
                self + utxo.output.value
            end
        end
    end
end
