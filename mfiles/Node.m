classdef Node < handle
    properties
        ID
        Name
        EIn
        EOut
        EAct
        EInh
        Value
        IC
        ECon
        NAct
        Parent
        EParent
        Child
        EChild
        Sibling
        ESibling
        Obs
        Type
        MolID
        BioName
        PathID
    end
    methods
        function obj = Node(id)
            obj.ID = id;
        end
    end
end
