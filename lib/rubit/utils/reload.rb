module Rubit
    module Reload
        extend self

        def reload!
            $LOADED_FEATURES.delete_if {|x| x.include? "rubit"}
            require_all "../lib/rubit/"
        end
    end
end
