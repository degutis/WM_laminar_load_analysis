function [correct_button, rt] = select_trials_behavior(numP,runType)

participants = {'S01','S02','S03','S04','S05','S06','S07','S08','S09'};

for p  = numP:numP
    csvFiles_load = dir(fullfile('..','data',participants{p},'beh','*load*.csv'));
    
    if runType ==1

%         subjectAv_lowLoad = [];
%         subjectAv_highLoad = [];
%         subjectAv_lowLoad_face = [];
%         subjectAv_lowLoad_scene = [];
%         subjectAv_highLoad_face = [];
%         subjectAv_highLoad_scene = [];
%         
%         subjectAv_lowLoad_rt = [];
%         subjectAv_highLoad_rt = [];
    
    correct_button = [];
    rt = [];
        
        for r = 1:2
            
            run = readtable(fullfile(csvFiles_load(r).folder,csvFiles_load(r).name));
            
            correct_button = [correct_button, run.keyResp_corr];
            rt = [rt, run.keyResp_rt];

%             subjectAv_lowLoad = [subjectAv_lowLoad;run.keyResp_corr(run.load==1)];
%             subjectAv_highLoad = [subjectAv_highLoad;run.keyResp_corr(run.load==4)];
% 
%             subjectAv_lowLoad_rt = [subjectAv_lowLoad_rt;run.keyResp_rt(run.load==1)];
%             subjectAv_highLoad_rt = [subjectAv_highLoad_rt;run.keyResp_rt(run.load==4)];
% 
%             subjectAv_lowLoad_face = [subjectAv_lowLoad_face;run.keyResp_corr(run.load==1 & (contains(run.category,'ff') | contains(run.category,'fm')))];
%             subjectAv_lowLoad_scene = [subjectAv_lowLoad_scene;run.keyResp_corr(run.load==1 & (contains(run.category,'so') | contains(run.category,'si')))];
%     
%             subjectAv_highLoad_face = [subjectAv_highLoad_face;run.keyResp_corr(run.load==4 & (contains(run.category,'ff') | contains(run.category,'fm')))];
%             subjectAv_highLoad_scene = [subjectAv_highLoad_scene;run.keyResp_corr(run.load==4 & (contains(run.category,'so') | contains(run.category,'si')))];
            
        end
        

    elseif runType==2
        
        error("Not implemeted yet")

        csvFiles_motor = dir(fullfile('..','data',participants{p},'beh','*motor*.csv'));
        
        subjectAv_response = [];
        subjectAv_abstain = [];
        subjectAv_response_face = [];
        subjectAv_response_scene = [];
        subjectAv_abstain_face = [];
        subjectAv_abstain_scene = [];
    
     
        for r = 1:2
            
            run = readtable(fullfile(csvFiles_motor(r).folder,csvFiles_motor(r).name));
            
            subjectAv_response = [subjectAv_response; run.keyResp_corr(contains(run.arrowDir,'?') & ~contains(run.keyResp_keys,'None'))];
            subjectAv_abstain = [subjectAv_abstain;run.keyResp_corr(contains(run.arrowDir,'x'))];
        
            subjectAv_response_face = [subjectAv_response_face;run.keyResp_corr(contains(run.arrowDir,'?') & (contains(run.category,'ff') | contains(run.category,'fm')))];
            subjectAv_response_scene = [subjectAv_response_scene;run.keyResp_corr(contains(run.arrowDir,'?') & (contains(run.category,'so') | contains(run.category,'si')))];
    
            subjectAv_abstain_face = [subjectAv_abstain_face;run.keyResp_corr(contains(run.arrowDir,'x') & (contains(run.category,'ff') | contains(run.category,'fm')))];
            subjectAv_abstain_scene = [subjectAv_abstain_scene;run.keyResp_corr(contains(run.arrowDir,'x') & (contains(run.category,'so') | contains(run.category,'si')))];    
        end
    end
end