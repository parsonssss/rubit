module Rubit
    module Serialize

        def serialize(item)
            item.to_yaml
        end


        def deserialize(item)
            YAML.load(item)
        end
    end
end
