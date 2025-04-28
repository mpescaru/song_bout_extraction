function seg_csv_to_mat (input_directory)
%%%Function takes as input a directory with .wav files and a segmentation
%%%generated using WhisperSeg and transforms the Segmentation csv into .mat
%%%files for evsonganaly

    [~, dir_name] = fileparts(input_directory); 
    seg_file_path = fullfile(input_directory, 'Segmentations', [dir_name, '.csv']); 
    seg_data = readtable(seg_file_path); 

    unique_files = unique(seg_data.files);

    for i = 1:length(unique_files)
        file_name = unique_files{i}; 

        file_rows = seg_data(string(seg_data.files)==file_name, :); 
        onsets = file_rows.onsets * 1000; 
        offsets = file_rows.offsets * 1000; 


        onsets = onsets(:);
        offsets = offsets(:);

        fname = fullfile(input_directory, file_name); 
        labels = repmat('0', 1, length(onsets));
        [~, Fs] = audioread(fname);
        min_int = 5; 
        min_dur = 20; 
        threshold = 4.0000e-06;
        sm_win = 2;

        save(fullfile(input_directory, [file_name, '.not.mat']),'Fs', 'fname', 'labels', 'onsets', 'offsets', 'min_int', 'min_dur', 'threshold', 'sm_win'); 
    end 
    disp('Segmentation file turned into MATLAB annotations! :)');
end 