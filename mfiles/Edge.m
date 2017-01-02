classdef Edge < handle
    properties
        ID
        Name
        Type
        NIn
        NOut
        NAct
        NInh
        Speed
        Prio
        Erev
        NCon
        IntID
        PathID
    end
    methods
        function obj = Edge(id)
            obj.ID = id;
        end
    end
end
