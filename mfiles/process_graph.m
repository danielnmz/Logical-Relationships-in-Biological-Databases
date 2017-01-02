function [pg,pg_u] = process_graph(N,E,P,p)
if nargin == 4
    E_list = [];
    N_list = [];
    for ii = 1:1:size(p,2)
        if p(1,ii) <= size(P,2)
            E_list = [E_list P(p(ii)).E];
            N_list = [N_list P(p(ii)).N];
        end
    end
    E_list = sort(unique(E_list));
    N_list = sort(unique(N_list));
    if isempty(E_list) == 0
        edge_counter = 0;
        for ii = 1:1:size(E_list,2)
            edge_counter = edge_counter + 1;
            E2(edge_counter) = Edge(edge_counter);
            E2(edge_counter).Name = E(E_list(ii)).Name;
            E2(edge_counter).Type = E(E_list(ii)).Type;
            E2(edge_counter).IntID = E(E_list(ii)).IntID;
            E2(edge_counter).PathID = E(E_list(ii)).PathID;
            [tf,index] = ismember(E(E_list(ii)).NIn,N_list);
            E2(edge_counter).NIn = index;
            [tf,index] = ismember(E(E_list(ii)).NAct,N_list);
            E2(edge_counter).NAct = index;
            [tf,index] = ismember(E(E_list(ii)).NInh,N_list);
            E2(edge_counter).NInh = index;
            [tf,index] = ismember(E(E_list(ii)).NOut,N_list);
            E2(edge_counter).NOut = index;
        end
        node_counter = 0;
        for ii = 1:1:size(N_list,2)
            node_counter = node_counter + 1;
            N2(node_counter) = Node(node_counter);
            N2(node_counter).Name = N(N_list(ii)).Name;
            N2(node_counter).BioName = N(N_list(ii)).BioName;
            N2(node_counter).Type = N(N_list(ii)).Type;
            N2(node_counter).MolID = N(N_list(ii)).MolID;
            N2(node_counter).PathID = N(N_list(ii)).PathID;
            [tf,index] = ismember(N(N_list(ii)).EIn,E_list);
            N2(node_counter).EIn = index;
            [tf,index] = ismember(N(N_list(ii)).EAct,E_list);
            N2(node_counter).EAct = index;
            [tf,index] = ismember(N(N_list(ii)).EInh,E_list);
            N2(node_counter).EInh = index;
            [tf,index] = ismember(N(N_list(ii)).EOut,E_list);
            N2(node_counter).EOut = index;
        end
        clear N E
        N = N2;
        E = E2;
    else
        N = [];
        E = [];
    end
end
if isempty(N) == 0 && isempty(E) == 0
    N_set_1 = [];
    N_set_2 = [];
    label = [];
    NCon_num = size(findobj(N,'Type','control'),1);
    process_counter = size(N,2) - NCon_num;
    for ii = 1:1:size(E,2)
        process_counter = process_counter + 1;
        N_set_1 = [N_set_1 E(ii).NIn E(ii).NAct E(ii).NInh process_counter*ones(1,size(E(ii).NOut,2))];
        N_set_2 = [N_set_2 process_counter*ones(1,size(E(ii).NIn,2)+size(E(ii).NAct,2)+size(E(ii).NInh,2)) E(ii).NOut];
    end
    for ii = 1:1:size(N,2)-NCon_num
        label = [label {N(ii).Name}];
    end
    for ii = 1:1:size(E,2)
        label = [label {E(ii).Name}];
    end
    E_weight = ones(1,size(N_set_1,2));
    g = sparse(N_set_1,N_set_2,E_weight,size(N,2)-NCon_num+size(E,2),size(N,2)-NCon_num+size(E,2));
    pg = biograph(g,label);
    g_u = tril(g+g');
    pg_u = biograph(g_u,label,'ShowArrows','off');
    for ii = 1:1:size(N,2)-NCon_num
        set(pg.nodes(ii),'Description',['N#',num2str(ii),'  MolID: ',N(ii).MolID,'  PathID: ',num2str(N(ii).PathID),'  BioName: ',N(ii).BioName,'  Type: ',N(ii).Type]);
        pg.nodes(ii).UserData = 'node';
    end
    for ii = 1:1:size(E,2)
        set(pg.nodes(ii+size(N,2)),'Description',['E#',num2str(ii),'  IntID: ',E(ii).IntID,'  PathID: ',num2str(E(ii).PathID),'  Type: ',E(ii).Type]);
        pg.nodes(ii+size(N,2)).Shape = 'circle';
        pg.nodes(ii+size(N,2)).UserData = 'edge';
    end
    for ii = 1:1:size(E,2)
        if size(E(ii).NAct,2) > 0
            for jj = 1:1:size(E(ii).NAct,2)
                set(find(pg.edges,'ID',[N(E(ii).NAct(1,jj)).Name,' -> ',E(ii).Name]),'Label','Activation','LineColor',[0 0 1],'LineWidth',1); % blue color for activators
            end
        end
        if size(E(ii).NInh,2) > 0
            for jj = 1:1:size(E(ii).NInh,2)
                set(find(pg.edges,'ID',[N(E(ii).NInh(1,jj)).Name,' -> ',E(ii).Name]),'Label','Inhibition','LineColor',[1 0 0],'LineWidth',1); % red color for inhibitors
            end
        end
    end
    set(pg.nodes,'Color',[1 1 1]);
else
    pg = [];
end
