% Class file defining pathway

classdef Pathway < handle
    properties
        ID
        Name
        ShortName
        N
        E
        PathID
    end
    methods
        function obj = Pathway(id)
            obj.ID = id;
        end
    end
end
