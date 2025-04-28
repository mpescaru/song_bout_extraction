function mat_to_csv_avn (directoryPath)

%%Function takes as input a directory containing .wav and .mat files and
%%creates a directory .csv file that concatenates all the .mat file onsets 
%%and offsets for avn
    
    %cd (directoryPath)  
   
    %load all .not.mat files 
    matFiles = dir(fullfile(directoryPath, '*.not.mat'));
    wavFiles = dir(fullfile(directoryPath, '*.wav'));
    [~,dirName] = fileparts(directoryPath);
    
    
    segDir = fullfile(directoryPath, 'Segmentations');
    disp(segDir);
    mkdir(segDir);

    %Extract filename for csv file
    csvFileName = fullfile(directoryPath, 'Segmentations', [dirName, '.csv']); 
    %csvFileName = [csvFileName, 'csv']
    disp(['CSV File Path: ' csvFileName]);


    if exist(csvFileName, 'file')
        delete(csvFileName);
    end 

    fid = fopen(csvFileName, 'w');
    
    if fid == -1
        error('Failed to open file: %s', csvFileName);
    end

    % Write header if needed
    fprintf(fid, ',onsets,offsets,files\n'); 

    %loop through .mat files and create corresponding .csv file
    for i = 1:length(matFiles)

        %Load .mat file
        filename = fullfile(directoryPath, matFiles(i).name);
        data = load(filename);
        wavName = matFiles(i).name(1:end-8);
        wavFilePath = fullfile(directoryPath, wavName);

        if isfield(data, 'onsets') && isfield(data, 'offsets') && isfile (wavFilePath)

            for j = 1:length (data.onsets)
                % Write data

                onset = sprintf('%.8f', data.onsets(j)/1000);
                offset = sprintf('%.8f', data.offsets(j)/1000);
                %onset = data.onsets(j)/1000;
                %offset = data.onsets(j)/1000;

                fprintf(fid, '%i,%s,%s,%s\n', (j-1), onset, offset, wavName);
            end 

            % Close file

            fprintf('Added %s to csv file \n', matFiles(i).name);
        else
            fprintf('Dataloading from /mat is the issue here. :) \n');
        end 
    end 
    fclose(fid);

    fprintf('All .mat have been added to csv\n');

