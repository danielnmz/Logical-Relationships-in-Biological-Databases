function [N,E,P] = read_data(database_file,par1)
[pathstr,name,ext] = fileparts(database_file);
if strcmp(ext,'.txt') == 1
    [N,E,P] = read_data_txt(database_file,par1);
elseif strcmp(ext,'.xml') == 1
    [N,E,P] = read_data_xml(database_file,par1);
end
end
function [N,E,P] = read_data_txt(database_file,par1)
fid = fopen(database_file,'r');
data_base = textscan(fid,'%s','delimiter','\n');
fclose(fid);
DataType = 'Process';
line_counter = 1;
node_counter = 0;
edge_counter = 0;
control_node_counter = 0;
Ntemp = [];
while strcmp(DataType,'Process') == 1
    line_counter = line_counter + 1;
    if strcmp(data_base{1}{line_counter},'<ObservableNodes>') == 1
        DataType = 'ObservableNodes';
        break
    elseif strcmp(data_base{1}{line_counter},'<InitialConditions>') == 1
        DataType = 'InitialConditions';
        break
    elseif strcmp(data_base{1}{line_counter},'<End>') == 1
        break
    elseif size(data_base{1}{line_counter},1) ~= 0
        if strcmp(data_base{1}{line_counter},'Process') == 1
            edge_counter = edge_counter + 1;
            E(edge_counter) = Edge(edge_counter);
            E(edge_counter).Name = sprintf('e_%d',edge_counter);
        end
        line_data = textscan(data_base{1}{line_counter},'%s %s %s %s %s %s %s');
        if strcmp(line_data{1},'Type') == 1 && size(line_data{2},1) ~= 0
            E(edge_counter).Type = char(line_data{2});
        end
        if strcmp(line_data{1},'Input') == 1
            for ii = 2:1:size(line_data,2)
                if size(line_data{ii},1) ~= 0
                    if exist('N') == 1
                        Ntemp = findobj(N,'BioName',char(line_data{ii}));
                        if size(Ntemp,1) > 0
                            E(edge_counter).NIn = sort([E(edge_counter).NIn Ntemp.ID]);
                            N(Ntemp.ID).EOut = sort([N(Ntemp.ID).EOut edge_counter]);
                        end
                    end
                    if size(Ntemp,1) == 0 || exist('N') == 0
                        node_counter = node_counter + 1;
                        N(node_counter) = Node(node_counter);
                        N(node_counter).Name = sprintf('n_%d',node_counter);
                        N(node_counter).BioName = char(line_data{ii});
                        N(node_counter).EOut = sort([N(node_counter).EOut edge_counter]);
                        E(edge_counter).NIn = sort([E(edge_counter).NIn N(node_counter).ID]);
                    end
                end
            end
        end
        if strcmp(line_data{1},'Output') == 1
            for ii = 2:1:size(line_data,2)
                if size(line_data{ii},1) ~= 0
                    if exist('N') == 1
                        Ntemp = findobj(N,'BioName',char(line_data{ii}));
                        if size(Ntemp,1) > 0
                            E(edge_counter).NOut = sort([E(edge_counter).NOut Ntemp.ID]);
                            N(Ntemp.ID).EIn = sort([N(Ntemp.ID).EIn edge_counter]);
                        end
                    end
                    if size(Ntemp,1) == 0 || exist('N') == 0
                        node_counter = node_counter + 1;
                        N(node_counter) = Node(node_counter);
                        N(node_counter).Name = sprintf('n_%d',node_counter);
                        N(node_counter).BioName = char(line_data{ii});
                        N(node_counter).EIn = sort([N(node_counter).EIn edge_counter]);
                        E(edge_counter).NOut = sort([E(edge_counter).NOut N(node_counter).ID]);
                    end
                end
            end
        end
        if strcmp(line_data{1},'Activator') == 1
            for ii = 2:1:size(line_data,2)
                if size(line_data{ii},1) ~= 0
                    if exist('N') == 1
                        Ntemp = findobj(N,'BioName',char(line_data{ii}));
                        if size(Ntemp,1) > 0
                            E(edge_counter).NAct = sort([E(edge_counter).NAct Ntemp.ID]);
                            N(Ntemp.ID).EAct = sort([N(Ntemp.ID).EAct edge_counter]);
                        end
                    end
                    if size(Ntemp,1) == 0 || exist('N') == 0
                        node_counter = node_counter + 1;
                        N(node_counter) = Node(node_counter);
                        N(node_counter).Name = sprintf('n_%d',node_counter);
                        N(node_counter).BioName = char(line_data{ii});
                        N(node_counter).EAct = sort([N(node_counter).EAct edge_counter]);
                        E(edge_counter).NAct = sort([E(edge_counter).NAct N(node_counter).ID]);
                    end
                end
            end
        end
        if strcmp(line_data{1},'Inhibitor') == 1
            for ii = 2:1:size(line_data,2)
                if size(line_data{ii},1) ~= 0
                    if exist('N') == 1
                        Ntemp = findobj(N,'BioName',char(line_data{ii}));
                        if size(Ntemp,1) > 0
                            E(edge_counter).NInh = sort([E(edge_counter).NInh Ntemp.ID]);
                            N(Ntemp.ID).EInh = sort([N(Ntemp.ID).EInh edge_counter]);
                        end
                    end
                    if size(Ntemp,1) == 0  || exist('N') == 0
                        node_counter = node_counter + 1;
                        N(node_counter) = Node(node_counter);
                        N(node_counter).Name = sprintf('n_%d',node_counter);
                        N(node_counter).BioName = char(line_data{ii});
                        N(node_counter).EInh = sort([N(node_counter).EInh edge_counter]);
                        E(edge_counter).NInh = sort([E(edge_counter).NInh N(node_counter).ID]);
                    end
                end
            end
        end
        if strcmp(line_data{1},'Speed') == 1 && size(line_data{2},1) ~= 0
            E(edge_counter).Speed = char(line_data{2});
        end
        if strcmp(line_data{1},'Priority') == 1 && size(line_data{2},1) ~= 0
            E(edge_counter).Prio = str2double(char(line_data{2}));
        end
    end
end
if strcmp(par1,'yes') == 1
    for ii = 1:1:size(E,2)
        if isempty(E(ii).NIn) == 0 && isempty(E(ii).NAct) == 0
            edge_counter = edge_counter + 1;
            E(edge_counter) = Edge(edge_counter);
            E(edge_counter).NIn = E(ii).NOut;
            E(edge_counter).NOut = E(ii).NIn;
            E(edge_counter).NInh = E(ii).NAct;
            E(edge_counter).Erev = E(ii).ID;
        end
    end
end
while strcmp(DataType,'ObservableNodes') == 1
    line_counter = line_counter + 1;
    if strcmp(data_base{1}{line_counter},'<InitialConditions>') == 1
        DataType = 'InitialConditions';
        break
    elseif strcmp(data_base{1}{line_counter},'<End>') == 1
        break
    elseif size(data_base{1}{line_counter},1) ~= 0
        line_data = textscan(data_base{1}{line_counter},'%s');
        Ntemp = findobj(N,'BioName',char(line_data{1}));
        if size(Ntemp,1) == 0
            fprintf(['The node ',char(line_data{1}),' is not defined in the process list. \n'])
        elseif size(Ntemp,1) == 1
            N(Ntemp.ID).Obs = 'yes';
        elseif size(Ntemp,1) > 1
            fprintf(['More than one node is associated with ',char(line_data{1}),'... Process or node list should be updated. \n'])
        end
    end
end
flag_IC = 0;
num_IC = 0;
while strcmp(DataType,'InitialConditions') == 1
    line_counter = line_counter + 1;
    if strcmp(data_base{1}{line_counter},'<End>') == 1
        break
    elseif size(data_base{1}{line_counter},1) ~= 0
        line_data = textscan(data_base{1}{line_counter},'%s %s %s %s %s %s %s %s %s %s %s %s %s');
        N_temp = findobj(N,'BioName',char(line_data{1}{1}));
        if isempty(N_temp) == 0
            for ii = 2:1:size(line_data,2)
                if isempty(line_data{ii}) == 0
                    N(N_temp.ID).IC = [N(N_temp.ID).IC str2double(line_data{ii}{1})];
                end
            end
            if flag_IC == 0
                num_IC = size(N(N_temp.ID).IC,2);
                flag_IC = 1;
            end
        end
    end
end
if num_IC > 0
    for ii = 1:1:size(N,2)
        if isempty(N(ii).IC) == 1
            if strcmp(N(ii).Type,'control') == 0
                N(ii).IC = zeros(1,num_IC);
            elseif strcmp(N(ii).Type,'control') == 1
                N(ii).IC = ones(1,num_IC);
            end
        end
    end
end
if exist('P') == 0
    network_counter = 1;
    P(network_counter) = Network(network_counter);
    P(network_counter).E = 1:1:size(E,2);
    P(network_counter).N = 1:1:size(N,2);
end
end
function [N,E,P] = read_data_xml(database_file,par1)
import javax.xml.parsers.*;
domFactory = DocumentBuilderFactory.newInstance();
builder = domFactory.newDocumentBuilder();
xml_data_temp = builder.parse(database_file);
xml_data = xml2struct(xml_data_temp);
xml_data_cell = struct2cell(xml_data);
Model = xml_data_cell{1}.Model;
EdgeList = struct2cell(Model.InteractionList);
if size(EdgeList{1},2) > 1
    EdgeList = EdgeList{1};
end
EdgeSize = size(EdgeList,2);
node_counter = 0;
edge_counter = 0;
Ntemp = [];
for ii = 1:1:EdgeSize
    edge_counter = edge_counter + 1;
    E(edge_counter) = Edge(edge_counter);
    E(edge_counter).Name = sprintf('e_%d',edge_counter);
    E(edge_counter).IntID = EdgeList{edge_counter}.Attributes.id;
    E(edge_counter).Type = EdgeList{edge_counter}.Attributes.interaction_type;
    clear x
    if strcmp(fieldnames(EdgeList{ii}.InteractionComponentList),'InteractionComponent') == 1
        x = struct2cell(EdgeList{ii}.InteractionComponentList);
        if size(x{1},2) > 1
            x = x{1};
        end
        for jj = 1:1:size(x,2)
            NodeBioName = [];
            id = x{jj}.Attributes.molecule_idref;
            NodeBioName = id;
            y = fieldnames(x{jj});
            for mm = 1:1:size(y,1)
                if strcmp(y(mm),'Label') == 1
                    if size(x{jj}.Label,2) == 1
                        NodeBioName =  [NodeBioName '-' x{jj}.Label.Attributes.value];
                    elseif size(x{jj}.Label,2) > 1
                        for kk = 1:1:size(x{jj}.Label,2)
                            NodeBioName =  [NodeBioName '-' x{jj}.Label{kk}.Attributes.value];
                        end
                    end
                end
                if strcmp(y(mm),'PTMExpression') == 1
                    z = struct2cell(x{jj}.PTMExpression);
                    if size(z{1},2) > 1
                        z = z{1};
                    end
                    if size(z,2) == 1
                        NodeBioName =  [NodeBioName '-protein:' z{1}.Attributes.protein 'position:' z{1}.Attributes.position 'modification:' z{1}.Attributes.modification];
                    elseif size(z,2) > 1
                        for kk = 1:1:size(z,2)
                            NodeBioName =  [NodeBioName '-protein:' z{kk}.Attributes.protein 'position:' z{kk}.Attributes.position 'modification:' z{kk}.Attributes.modification];
                        end
                    end
                end
            end
            if strcmp(x{jj}.Attributes.role_type,'input') == 1
                if exist('N') == 1
                    Ntemp = findobj(N,'BioName',NodeBioName);
                    if size(Ntemp,1) > 0
                        E(edge_counter).NIn = sort([E(edge_counter).NIn Ntemp.ID]);
                        N(Ntemp.ID).EOut = sort([N(Ntemp.ID).EOut edge_counter]);
                    end
                end
                if isempty(Ntemp) == 1 || exist('N') == 0
                    node_counter = node_counter + 1;
                    N(node_counter) = Node(node_counter);
                    N(node_counter).Name = sprintf('n_%d',node_counter);
                    N(node_counter).MolID = id;
                    N(node_counter).BioName = NodeBioName;
                    N(node_counter).EOut = sort([N(node_counter).EOut edge_counter]);
                    E(edge_counter).NIn = sort([E(edge_counter).NIn N(node_counter).ID]);
                end
            elseif strcmp(x{jj}.Attributes.role_type,'output') == 1
                if exist('N') == 1
                    Ntemp = findobj(N,'BioName',NodeBioName);
                    if size(Ntemp,1) > 0
                        E(edge_counter).NOut = sort([E(edge_counter).NOut Ntemp.ID]);
                        N(Ntemp.ID).EIn = sort([N(Ntemp.ID).EIn edge_counter]);
                    end
                end
                if isempty(Ntemp) == 1 || exist('N') == 0
                    node_counter = node_counter + 1;
                    N(node_counter) = Node(node_counter);
                    N(node_counter).Name = sprintf('n_%d',node_counter);
                    N(node_counter).MolID = id;
                    N(node_counter).BioName = NodeBioName;
                    N(node_counter).EIn = sort([N(node_counter).EIn edge_counter]);
                    E(edge_counter).NOut = sort([E(edge_counter).NOut N(node_counter).ID]);
                end
            elseif strcmp(x{jj}.Attributes.role_type,'agent') == 1
                if exist('N') == 1
                    Ntemp = findobj(N,'BioName',NodeBioName);
                    if size(Ntemp,1) > 0
                        E(edge_counter).NAct = sort([E(edge_counter).NAct Ntemp.ID]);
                        N(Ntemp.ID).EAct = sort([N(Ntemp.ID).EAct edge_counter]);
                    end
                end
                if isempty(Ntemp) == 1 || exist('N') == 0
                    node_counter = node_counter + 1;
                    N(node_counter) = Node(node_counter);
                    N(node_counter).Name = sprintf('n_%d',node_counter);
                    N(node_counter).MolID = id;
                    N(node_counter).BioName = NodeBioName;
                    N(node_counter).EAct = sort([N(node_counter).EAct edge_counter]);
                    E(edge_counter).NAct = sort([E(edge_counter).NAct N(node_counter).ID]);
                end
            elseif strcmp(x{jj}.Attributes.role_type,'inhibitor') == 1
                if exist('N') == 1
                    Ntemp = findobj(N,'BioName',NodeBioName);
                    if size(Ntemp,1) > 0
                        E(edge_counter).NInh = sort([E(edge_counter).NInh Ntemp.ID]);
                        N(Ntemp.ID).EInh = sort([N(Ntemp.ID).EInh edge_counter]);
                    end
                end
                if isempty(Ntemp) == 1 || exist('N') == 0
                    node_counter = node_counter + 1;
                    N(node_counter) = Node(node_counter);
                    N(node_counter).Name = sprintf('n_%d',node_counter);
                    N(node_counter).MolID = id;
                    N(node_counter).BioName = NodeBioName;
                    N(node_counter).EInh = sort([N(node_counter).EInh edge_counter]);
                    E(edge_counter).NInh = sort([E(edge_counter).NInh N(node_counter).ID]);
                end
            end
        end
    end
    if isempty(E(edge_counter).NOut) == 1
        NodeBioName = E(edge_counter).Type;
        if exist('N') == 1
            Ntemp = findobj(N,'BioName',NodeBioName);
            if size(Ntemp,1) > 0
                E(edge_counter).NOut = sort([E(edge_counter).NOut Ntemp.ID]);
                N(Ntemp.ID).EIn = sort([N(Ntemp.ID).EIn edge_counter]);
            end
        end
        if isempty(Ntemp) == 1 || exist('N') == 0
            node_counter = node_counter + 1;
            N(node_counter) = Node(node_counter);
            N(node_counter).Name = sprintf('n_%d',node_counter);
            N(node_counter).MolID = id;
            N(node_counter).BioName = NodeBioName;
            N(node_counter).EIn = sort([N(node_counter).EIn edge_counter]);
            E(edge_counter).NOut = sort([E(edge_counter).NOut N(node_counter).ID]);
        end
    end
end
PathwayList = struct2cell(Model.PathwayList);
if size(PathwayList{1},2) > 1
    PathwayList = PathwayList{1};
end
PathwaySize = size(PathwayList,2);
network_counter = 0;
for ii = 1:1:PathwaySize
    clear p
    if ismember('PathwayComponentList',fieldnames(PathwayList{ii})) == 1
        network_counter = network_counter + 1;
        P(network_counter) = Network(network_counter);
        P(network_counter).Name = char(struct2cell(PathwayList{ii}.LongName));
        P(network_counter).ShortName = char(struct2cell(PathwayList{ii}.ShortName));
        P(network_counter).PathID = PathwayList{ii}.Attributes.id;
        p = struct2cell(PathwayList{ii}.PathwayComponentList);
        if size(p{1},2) > 1
            p = p{1};
        end
        for jj = 1:1:size(p,2)
            int_id = p{jj}.Attributes.interaction_idref;
            Etemp = findobj(E,'IntID',int_id);
            if isempty(Etemp) == 0
                for kk = 1:1:size(Etemp,1)
                    E(Etemp(kk).ID).PathID = sort([E(Etemp(kk).ID).PathID network_counter]);
                    P(network_counter).E = [P(network_counter).E Etemp(kk).ID];
                    P(network_counter).N = [P(network_counter).N Etemp(kk).NIn Etemp(kk).NAct Etemp(kk).NInh Etemp(kk).NOut];
                end
            end
        end
    end
end
for ii = 1:1:size(N,2)
    for jj = 1:1:size(N(ii).EIn,2)
        N(ii).PathID = sort(unique([N(ii).PathID E(N(ii).EIn(1,jj)).PathID]));
    end
    for jj = 1:1:size(N(ii).EOut,2)
        N(ii).PathID = sort(unique([N(ii).PathID E(N(ii).EOut(1,jj)).PathID]));
    end
    for jj = 1:1:size(N(ii).EAct,2)
        N(ii).PathID = sort(unique([N(ii).PathID E(N(ii).EAct(1,jj)).PathID]));
    end
    for jj = 1:1:size(N(ii).EInh,2)
        N(ii).PathID = sort(unique([N(ii).PathID E(N(ii).EInh(1,jj)).PathID]));
    end
end
end
