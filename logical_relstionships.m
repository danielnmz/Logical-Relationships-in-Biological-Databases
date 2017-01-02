clear all
clc
% =======================  Input parameters  ==============================
save_network_plot = 'no'; % for NCI_PID_Database this may takes time, alternatively change it to 'no'
database_file = 'database\synthetic_network_example.txt';
% database_file = 'database\NCI_PID_Database.mat';
% database_file = 'database\NCI_PID_Database.xml'; % original .xml format which takes time to read. Use the above .mat format for faster read.

filename_print = 'Example';
n_o = 'n_1';
n_t = 'n_9';
L_o_input = [1 3]; % logic sequence for n_o (left to right) d=1, u=2, c=3, empty=[]
L_t_input = [2];  % logic sequence for n_t (left to right) d=1, u=2, c=3, empty=[]

% filename_print = 'ERBB2-MTOR';
% n_o = 'n_1526';  % ERBB2
% n_t = 'n_3099';  % mTOR+
% L_o_input = [1]; % logic sequence for n_o (left to right) d=1, u=2, c=3, empty=[]
% L_t_input = [];  % logic sequence for n_t (left to right) d=1, u=2, c=3, empty=[]

% filename_print = 'CBL-MTOR';
% n_o = 'n_961';   % CBL
% n_t = 'n_3099';  % mTOR+
% L_o_input = [1]; % logic sequence for n_o (left to right) d=1, u=2, c=3, empty=[]
% L_t_input = [];  % logic sequence for n_t (left to right) d=1, u=2, c=3, empty=[]

% ====================  Other Input parameters  ===========================
% Do not change this part unless you understand the code
search_depth = 20;
max_all_path = 30;

% ================  Computing Logical Relationships  ======================
fprintf('Loading database...\n')
if strcmp(database_file,'database\synthetic_network_example.txt') == 1
    [N,E,P] = read_data(database_file,'no');
    pathway_selected = 1;
elseif strcmp(database_file,'database\NCI_PID_Database.xml') == 1
    [N,E,P] = read_data(database_file,'no');
elseif strcmp(database_file,'database\NCI_PID_Database.mat') == 1
    load('database\NCI_PID_Database.mat','N','E','P');
else
    [N,E,P] = read_data(database_file,'no');
    pathway_selected = 1;
end

if strcmp(database_file,'database\NCI_PID_Database.xml') == 1 || strcmp(database_file,'database\NCI_PID_Database.mat') == 1
    Ntemp_o = findobj(N,'Name',n_o);
    Ntemp_t = findobj(N,'Name',n_t);
    pathway_selected = unique([Ntemp_o.PathID Ntemp_t.PathID]);
    for pp = 1:1:length(pathway_selected)
        for nn = 1:1:length(P(pp).N)
            pathway_selected = [pathway_selected N(P(pp).N(nn)).PathID];
        end
    end
    a = pathway_selected;
    b = unique(pathway_selected);
    pathway_selected = [];
    for ii = 1:1:length(b)
        if sum(a == b(ii)) > 6
            pathway_selected = [pathway_selected b(ii)];
        end
    end
    pathway_selected = unique([pathway_selected unique([Ntemp_o.PathID Ntemp_t.PathID])]);
end
fprintf(['# of selected pathways: ',num2str(length(pathway_selected)),'\n'])

fprintf('Converting database to biograph...\n')
[pg_selected,pg_u_selected] = process_graph(N,E,P,pathway_selected);
fprintf('\bOK\n')

% Save biograph as a figure ==========
if strcmp(save_network_plot,'yes') == 1
    g = biograph.bggui(pg_selected);
    f = figure;
    % axes('box','on')
    set(axes,'box','off')
    copyobj(g.biograph.hgAxes,f);
    printpdf(f,['results\',filename_print,'-network-plot.pdf'])
    close(f)
    % this part closes the biograph
    child_handles = allchild(0);
    names = get(child_handles,'Name');
    k = find(strncmp('Biograph Viewer', names, 15));
    close(child_handles(k))
end
% ==========

L_o = L_o_input; % fliplr(L_o_input);
L_t = L_t_input; % fliplr(L_t_input);

% strings of L_o and L_t for plots
L_o_str = num2str(L_o_input);
L_o_str(ismember(L_o_str,' ,.:;!')) = [];
L_t_str = num2str(L_t_input);
L_t_str(ismember(L_t_str,' ,.:;!')) = [];

N_o{1}{1} = find(pg_selected.nodes,'ID',n_o);
N_t{1}{1} = find(pg_selected.nodes,'ID',n_t);
N_o_all = N_o{1}{1};
N_t_all = N_t{1}{1};
fprintf('Applying nodal operator to n_o...\n')
for ii = 1:1:length(L_o)
    counter = 0;
    if L_o(ii) == 1
        if ii <= length(N_o)
            for jj = 1:1:length(N_o{ii})
                for kk = 1:1:length(N_o{ii}{jj})
                    if isempty(N_o{ii}{jj}) == 0
                        if strcmp(N_o{ii}{jj}(kk).UserData,'node') == 1
                            N_temp = setdiff(getdescendants(find(pg_selected.nodes,'ID',N_o{ii}{jj}(kk).ID),search_depth),N_o_all);
                            for nn = 1:1:length(N_temp)
                                counter = counter + 1;
                                N_o{ii+1}{counter} = N_temp(nn);
                                N_o_all = union(N_o_all,N_o{ii+1}{counter});
                            end
                        end
                    end
                end
            end
        end
    elseif L_o(ii) == 2
        error('Logic for L_o is not valid.')
    elseif L_o(ii) == 3
        if ii <= length(N_o)
            for jj = 1:1:length(N_o{ii})
                for kk = 1:1:length(N_o{ii}{jj})
                    if isempty(N_o{ii}{jj}) == 0
                        if strcmp(N_o{ii}{jj}(kk).UserData,'node') == 1
                            N_temp = getdescendants(find(pg_selected.nodes,'ID',N_o{ii}{jj}(kk).ID),1);
                            for ee = 1:1:length(N_temp)
                                if strcmp(N_temp(ee).UserData,'edge') == 1
                                    N_temp_2 = setdiff(getancestors(find(pg_selected.nodes,'ID',N_temp(ee).ID),1),N_o_all);
                                    for nn = 1:1:length(N_temp_2)
                                        if strcmp(N_temp_2(nn).UserData,'node') == 1
                                            E_temp_2 = getedgesbynodeid(pg_selected,N_temp_2(nn).ID,N_temp(ee).ID);
                                            if strcmp(E_temp_2.Label,'Activation') == 0 && strcmp(E_temp_2.Label,'Inhibition') == 0
                                                counter = counter + 1;
                                                N_o{ii+1}{counter} = N_temp_2(nn);
                                                N_o_all = union(N_o_all,N_o{ii+1}{counter});
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
fprintf('\bOK\n')
fprintf('Applying nodal operator to n_t...\n')
for ii = 1:1:size(L_t,2)
    counter = 0;
    if L_t(ii) == 1
        error('Logic for L_t is not valid.')
    elseif L_t(ii) == 2
        if ii <= size(N_t,2)
            for jj = 1:1:size(N_t{ii},2)
                for kk = 1:1:size(N_t{ii}{jj},1)
                    if isempty(N_t{ii}{jj}) == 0
                        if strcmp(N_t{ii}{jj}(kk).UserData,'node') == 1
                            N_temp = setdiff(getancestors(find(pg_selected.nodes,'ID',N_t{ii}{jj}(kk).ID),search_depth),N_t_all);
                            for nn = 1:1:length(N_temp)
                                counter = counter + 1;
                                N_t{ii+1}{counter} = N_temp(nn);
                                N_t_all = union(N_t_all,N_t{ii+1}{counter});
                            end
                        end
                    end
                end
            end
        end
    elseif L_t(ii) == 3
        error('Logic for L_t is not valid.')
    end
end
N_o_last = [];
for ii = 1:1:length(N_o{length(N_o)})
    N_o_last = union(N_o_last,N_o{length(N_o)}{ii});
end
N_t_last = [];
for ii = 1:1:length(N_t{length(N_t)})
    N_t_last = union(N_t_last,N_t{length(N_t)}{ii});
end
fprintf('\bOK\n')
fprintf('Calculating shared set...\n')
N_int = intersect(N_o_last,N_t_last);
fprintf('\bOK\n')
set(pg_selected.nodes,'Color',[1 1 1]);
if isempty(N_int) == 1
    fprintf(['No relationship is found for (L_o=[',L_o_str,'], L_t=[',L_t_str,']).\n'])
end
for ii = 1:1:length(N_o_last)
    set(N_o_last(ii),'Color',[0 1 0]); % green
end
for ii = 1:1:length(N_t_last)
    set(N_t_last(ii),'Color',[1 0 0]); % red
end
if isempty(N_int) == 0
    fprintf([num2str(length(N_int)),' shared nodes/edges are found.\n'])
    for ii = 1:1:length(N_int)
        set(N_int(ii),'Color',[0 0 1]); % blue
    end
end
% pg_selected.view
N_o_all_num = [];
N_o_all_logic = [];
N_t_all_num = [];
N_t_all_logic = [];
for ii = 1:1:length(N_o)
    for jj = 1:1:length(N_o{ii})
        N_o_all_num = [N_o_all_num find(pg_selected.nodes == N_o{ii}{jj})];
        if ii == 1
            N_o_all_logic = [N_o_all_logic 0];
        else
            N_o_all_logic = [N_o_all_logic L_o_input(ii-1)];
        end
    end
end
for ii = 1:1:length(N_t)
    for jj = 1:1:length(N_t{ii})
        N_t_all_num = [N_t_all_num find(pg_selected.nodes == N_t{ii}{jj})];
        if ii == 1
            N_t_all_logic = [N_t_all_logic 0];
        else
            N_t_all_logic = [N_t_all_logic L_t_input(ii-1)];
        end
    end
end

% calculating relationships
if isempty(N_int) == 0
    fprintf('Applying relationship operator...\n')
    c = [];
    a = find(pg_selected.nodes == find(pg_selected.nodes,'ID',n_o));
    b = find(pg_selected.nodes == find(pg_selected.nodes,'ID',n_t));
    if isempty(intersect(pg_selected.nodes,N_int)) == 0
        for ii = 1:1:length(N_int)
            c = [c find(pg_selected.nodes == N_int(ii))];
        end
    end
    if isempty(c) == 0
        fprintf('Constructing connectivity matrix...\n')
        num_visited_biograph_edges = 0;
        g_u = Inf(length(pg_u_selected.nodes),length(pg_u_selected.nodes));
        for nn = 1:1:length(N_o_all_num)
            node_id = N_o_all_num(nn);
            [disc, pred, closed] = traverse(pg_selected,node_id,'Depth',1,'Directed','true');
            disc = setdiff(disc,node_id);
            for dd = 1:1:length(disc)
                num_visited_biograph_edges = num_visited_biograph_edges + 1;
                g_u(node_id,disc(dd)) = 1;
                if N_o_all_logic(nn) == 3
                    g_u(disc(dd),node_id) = 1;
                end
            end
        end
        for nn = 1:1:length(N_t_all_num)
            node_id = N_t_all_num(nn);
            [disc_u, pred_u, closed_u] = traverse(pg_u_selected,node_id,'Depth',1,'Directed','false');
            [disc, pred, closed] = traverse(pg_selected,node_id,'Depth',1,'Directed','true');
            disc = setdiff(disc_u,[disc node_id]);
            for dd = 1:1:length(disc)
                num_visited_biograph_edges = num_visited_biograph_edges + 1;
                g_u(disc(dd),node_id) = 1;
                if N_t_all_logic(nn) == 3
                    g_u(node_id,disc(dd)) = 1;
                end
            end
        end
        fprintf(['# of edges considered in the biograph: ',num2str(num_visited_biograph_edges),'\n'])
        fprintf('Calculating relationships...\n')
        path_counter = 0;
        for ii = 1:1:length(c)
            [path_o, tot_cost_o] = kShortestPath(g_u,a,c(ii),max_all_path);
            [path_t, tot_cost_t] = kShortestPath(g_u,c(ii),b,max_all_path);
            if isempty(path_o) == 0 && isempty(path_t) == 0
                for oo = 1:1:length(path_o)
                    for tt = 1:1:length(path_t)
                        path_counter = path_counter + 1;
                        path_temp{path_counter} = unique([path_o{oo} path_t{tt}]);
                    end
                end
            elseif isempty(path_o) == 0
                for oo = 1:1:length(path_o)
                    path_counter = path_counter + 1;
                    path_temp{path_counter} = path_o{oo};
                end
            elseif isempty(path_t) == 0
                for tt = 1:1:length(path_t)
                    path_counter = path_counter + 1;
                    path_temp{path_counter} = path_t{tt};
                end
            end
        end
        fprintf('Relationships found.\n')
        path_counter = 0;
        for ii = 1:1:length(path_temp)
            similar_path = 0;
            for jj = ii+1:1:length(path_temp)
                if length(path_temp{ii}) == length(path_temp{jj})
                    if all(path_temp{ii} == path_temp{jj}) == 1
                        similar_path = 1;
                    end
                end
            end
            if similar_path == 0
                path_counter = path_counter + 1;
                path{path_counter} = path_temp{ii};
            end
        end
        for ii = 1:1:length(path) % this for-loop is to include other nodes of edges that are in the path connecting n_o and n_t
            for jj = 1:1:length(path{ii})
                if strcmp(pg_selected.nodes(path{ii}(jj)).UserData,'edge') == 1
                    Nanc = getancestors(pg_selected.nodes(path{ii}(jj)),1);
                    for kk = 1:1:size(Nanc,1)
                        for tt = 1:1:size(pg_selected.nodes,1)
                            if strcmp(pg_selected.nodes(tt).ID,Nanc(kk).ID) == 1
                                path{ii} = [path{ii} tt];
                            end
                        end
                    end
                    Ndes = getdescendants(pg_selected.nodes(path{ii}(jj)),1);
                    for kk = 1:1:size(Ndes,1)
                        for tt = 1:1:size(pg_selected.nodes,1)
                            if strcmp(pg_selected.nodes(tt).ID,Ndes(kk).ID) == 1
                                path{ii} = [path{ii} tt];
                            end
                        end
                    end
                end
            end
            path{ii} = unique(path{ii});
        end
        fprintf([num2str(length(path)),' relationships found for (L_o=[',L_o_str,'], L_t=[',L_t_str,']).\n'])
        fprintf('Plotting the relationships...\n')
        
        % Plotting the calculated relationships
        for ii = 1:1:length(path)
            [pg_temp,pg_u_temp] = process_graph(N,E,P,pathway_selected);
            label{ii} = [];
            edge_index{ii} = [];
            description{ii} = [];
            for jj = 1:1:size(path{ii},2)
                label{ii} = [label{ii} {pg_temp.nodes(path{ii}(jj)).ID}];
                if strcmp(pg_temp.nodes(path{ii}(jj)).UserData,'edge') == 1
                    edge_index{ii} = [edge_index{ii} jj];
                end
                description{ii} = [description{ii} {pg_temp.nodes(path{ii}(jj)).Description}];
            end
            node_del(pg_temp,setdiff([1:1:size(pg_temp.nodes,1)],path{ii}));
            Matrix = getmatrix(pg_temp);
            pg_temp = biograph(Matrix,label{ii});
            set(pg_temp.nodes,'Color',[1 1 1]);
            % set(find(pg_temp.nodes,'ID',n_o),'Color',[1 0 0]);
            % set(find(pg_temp.nodes,'ID',n_t),'Color',[1 1 0]);
            set(pg_temp.nodes(edge_index{ii}),'Shape','circle');
            for jj = 1:1:size(pg_temp.nodes,1)
                set(pg_temp.nodes(jj),'Description',description{ii}{jj});
            end
            set(pg_temp.nodes(edge_index{ii}),'UserData','edge');
            set(pg_temp.nodes(setdiff([1:1:size(pg_temp.nodes,1)],edge_index{ii})),'UserData','node');
            for jj = 1:1:size(edge_index{ii},2)
                Etemp = findobj(E,'Name',pg_temp.nodes(edge_index{ii}(jj)).ID);
                Eanc = setdiff(getancestors(pg_temp.nodes(edge_index{ii}(jj)),1),pg_temp.nodes(edge_index{ii}(jj)));
                for kk = 1:1:size(Eanc,1)
                    Ntemp = findobj(N,'Name',Eanc(kk).ID);
                    if ismember(Etemp.ID,Ntemp(1).EAct) == 1
                        set(find(pg_temp.edges,'ID',[Ntemp(1).Name,' -> ',Etemp.Name]),'Label','Activation','LineColor',[0 0 1],'LineWidth',1);
                    elseif ismember(Etemp.ID,Ntemp(1).EInh) == 1
                        set(find(pg_temp.edges,'ID',[Ntemp(1).Name,' -> ',Etemp.Name]),'Label','Inhibition','LineColor',[1 0 0],'LineWidth',1);
                    end
                end
                Edes = setdiff(getdescendants(pg_temp.nodes(edge_index{ii}(jj)),1),pg_temp.nodes(edge_index{ii}(jj)));
                if isempty(Edes) == 1
                    for kk = 1:1:size(Etemp.NOut,2)
                        Nadd = find(pg_temp.nodes,'ID',N(Etemp.NOut(1,kk)).Name);
                        if isempty(Nadd) == 1
                            node_add(pg_temp);
                            set(pg_temp.nodes(size(pg_temp.nodes,1)),'ID',N(Etemp.NOut(1,kk)).Name);
                            set(pg_temp.nodes(size(pg_temp.nodes,1)),'Color',[1 1 1]);
                            set(pg_temp.nodes(size(pg_temp.nodes,1)),'Description',['MolID: ',N(Etemp.NOut(1,kk)).MolID,'  PathID: ',num2str(N(Etemp.NOut(1,kk)).PathID),'  BioName: ',N(Etemp.NOut(1,kk)).BioName,'  Type: ',N(Etemp.NOut(1,kk)).Type]);
                            set(pg_temp.nodes(size(pg_temp.nodes,1)),'UserData','node');
                            edge_add(pg_temp,edge_index{ii}(jj),size(pg_temp.nodes,1),[.5 .5 .5]);
                        end
                    end
                end
            end
            % labels = [];
            for jj = 1:1:size(pg_temp.nodes,1)
                if strcmp(pg_temp.nodes(jj).UserData,'node') == 1
                    Ntemp = findobj(N,'Name',pg_temp.nodes(jj).ID);
                    set(pg_temp.nodes(jj),'ID',char(Ntemp.Name));
                elseif strcmp(pg_temp.nodes(jj).UserData,'edge') == 1
                    Etemp = findobj(E,'Name',pg_temp.nodes(jj).ID);
                    set(pg_temp.nodes(jj),'ID',char(Etemp.Name));
                end
            end
            if isempty(pg_temp.nodes) == 0
                % pg_temp.view
                % this part saves biograph as a figure
                g = biograph.bggui(pg_temp);
                f = figure;
                % axes('box','on')
                set(axes,'box','off')
                copyobj(g.biograph.hgAxes,f);
                printpdf(f,['results\',filename_print,'-f',num2str(ii),'(',n_o,',',n_t,'),(',L_o_str,',',L_t_str,').pdf'])
                close(f)
                % this part closes the biograph
                child_handles = allchild(0);
                names = get(child_handles,'Name');
                k = find(strncmp('Biograph Viewer', names, 15));
                close(child_handles(k))
            end
        end
        fprintf('Calculation is complete.\n')
    else
        fprintf(['No relationship is found for (L_o=[',L_o_str,'], L_t=[',L_t_str,']).\n'])
    end
end
