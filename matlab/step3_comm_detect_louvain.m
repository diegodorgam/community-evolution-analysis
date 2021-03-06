%step3_comm_detect_louvain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intellectual Property of ITI (CERTH)%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This .m file detects the communities in each adjacency matrix as well as%
% the sizes of the communities and the modularity for each timeslot using %
% Louvain mentod (V. D. Blondel, J.-L. Guillaume, R. Lambiotte, and       %
% E. Lefebvre. Fast unfolding of communities in large networks. Journal   %
% of Statistical Mechanics: Theory and Experiment, 2008(10):P10008 (12pp),%
% 2008.).                                                                 %
% In the case of small datasets enable recursive computation by setting   %
% the recursive var to 1.                                                 %
% It can either work as a standalone script or as a function for the main %
% m-file                                                                  %
% Please comment the function lines below accordingly                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function step3_comm_detect_louvain(folder_name,recursive,timeSeg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stand alone script %%comment the following 5 lines if you need the fn
% recursive=0;
% folder_name=uigetdir; %%Or this line if you need the function %%select the directory of interest
% timeSeg=1800; % Change the value of timeSeg in respect to the desired time sampling interval (seconds)
%%%Sampling time values {600 1800 3600 21600 43200 86400};%%%%%%%%%

mkdir(folder_name,['\data\mats\timeSeg_',num2str(timeSeg)]);
CommDir=dir([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat*.mat']);
lDir=length(CommDir);
mymodularity=zeros(1,lDir);
commSizes=zeros(lDir,1);
cellAdjMat=cell(lDir,1);
%load all the adjMats into a cell array
for k=1:lDir%%%%%%%%%%%%%%%%%%%%%%
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\adjMat_',num2str(k),'.mat']);
    cellAdjMat{k,1}=adjMat;
end
if ~matlabpool('size')
matlabpool open
end
commStructure=cell(lDir,1);
% detect communities for each timeslot
parfor k2=1:lDir
    [comm_struct,~] = comm_detect_louvain(cellAdjMat{k2},recursive,0,0,0);
    mymodularity(k2)=comm_struct.MOD;
    commStructure{k2}=comm_struct;
end
% save the structure resulting from the louvain code for all timeslots
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commStructure.mat'],'commStructure');
if matlabpool('size')
    matlabpool close
end
% save the structure resulting from the louvain code for all timeslots
for k=1:lDir%%%%%%%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!!!
    comm_struct=commStructure{k};
    commSizes(k,1:length(comm_struct.SIZE{1}))=comm_struct.SIZE{1};
    strComms=cell(1,max(comm_struct.COM{1}));
    numComms=cell(1,max(comm_struct.COM{1}));
    tempUsersCommNums=comm_struct.COM{1};
    load([folder_name,'\data\mats\adjMats\timeSeg_',num2str(timeSeg),'\tempUsers_',num2str(k),'.mat']);
    for i=1:max(comm_struct.COM{1})
        numUsers=find(comm_struct.COM{1}==i);
        strComms{i}=tempUsers(numUsers,1);
        numComms{i}=sort(cell2mat(tempUsers(numUsers,2)));
    end
    %save cell array of communities with real names
    save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\strComms',num2str(k),'.mat'],'strComms');
    %save cell array of communities with their uniqueUsers' indices
    save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\numComms',num2str(k),'.mat'],'numComms');
    %save corresponding community number to each user
    save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\tempUsersCommNums',num2str(k),'.mat'],'tempUsersCommNums');
end
%save a modularity vector for each timeslot
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\modularity.mat'],'mymodularity');
% save community sizes
save([folder_name,'\data\mats\timeSeg_',num2str(timeSeg),'\commSizes.mat'],'commSizes');

