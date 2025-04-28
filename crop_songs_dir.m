function crop_songs_dir (input_directory, output_directory, use_mat)
%%% function crops out song bouts from .wav files in input directories. Set
%%% mat_files to 0 if the directory does not contain .not.mat files 
% (but has a Segmentation folder from WhisperSeg). Set to anything else
% otherwise 
    
    if use_mat == 0
        seg_csv_to_mat(input_directory);
        
    end 
    mat_files = dir(fullfile(input_directory, '*.not.mat')); 
    for i = 1:length(mat_files)
        mat_file = mat_files(i).name; 
        crop_songs_file (mat_file, input_directory, output_directory);
    end 
    mat_to_csv_avn(output_directory); 

end 


function crop_songs_file (mat_file, in_dir, out_dir)
%%% function is given an annotation file (mat_file) and the directory (in_dir) with the
%%% corresponding wav_file. It crops out song segments and stores the data
%%% in out_dir
    fprintf("Working on file %s\n", mat_file);
    mat_file_path = fullfile(in_dir, mat_file);
    wav_file = mat_file(1:end-8);
    wav_file_path = fullfile(in_dir, wav_file); 
    
    %%%read data from files 
    [audio_data, fs] = audioread(wav_file_path); 
    not_data = load(mat_file_path); 

    %%%parameters, can adjust
    window = 1; 
    increment = 0.1; 
    nb_syll = 4; %minimum number of syllables in a 1 second window
    song_nb_syll = 6; %minimum number of syllables in a full bout
    zero_windows_accepted = 12; 

    nb_windows = floor(length(audio_data)/fs * window/increment - 1); 
    found_song = zeros(nb_windows, 1); 
   
    %disp(not_data.onsets); 

    %%%create array of song bouts (1) and silence (0)
    fprintf("Finding song windows.\n")
    for i = 0: nb_windows - 1
        start_win = i*0.1*fs; 
        end_win = start_win + fs; 

        syllable_count = 0; 

        for j = 1:length(not_data.onsets)
            if (not_data.onsets(j)/1000*fs <= end_win && not_data.onsets(j)/1000*fs >= start_win) && ...
                    (not_data.offsets(j)/1000*fs <= end_win && not_data.offsets(j)/1000*fs >= start_win)
                %fprintf('syllable included: (%d, %d) in window %d, %d\n', not_data.onsets(j), not_data.offsets(j), start_win/fs*1000, end_win/fs*1000);
                syllable_count = syllable_count + 1;
            end 
        end 
        if syllable_count >= nb_syll 
            found_song(i + 1) = 1; 
        end 
    end 

    %%%find start and end point of song bouts 
    bout_count = 0; 
    bout_start = []; 
    bout_end = []; 
    string_0 = 0; 
    string_1 = 0;
    fprintf("Finding start and end of song segments.\n")
    %disp(found_song);
    for i = 1 : nb_windows
        if found_song(i) == 1 && (i==1 || found_song(i-1)==0)
            if string_0 > zero_windows_accepted || bout_count == 0           
                win_start = (i-1)*0.1*1000; 
                %fprintf('win_start= %d\n', win_start); 
                bout_start = [bout_start, win_start];
                bout_count = bout_count + 1;
                if bout_count ~= 1
                    win_end = (i-string_0-1)*0.1*1000 + 1000; 
                 %   fprintf('win_end= %d\n', win_end); 
                    bout_end = [bout_end, win_end]; 
                end 
            end 
            string_0 = 0; 
        else 
            if found_song(i) == 0 
                string_0 = string_0 + 1;
            end 
        end 
        
    end 
    if bout_count ~= 0
        win_end = ((nb_windows-string_0-1)*0.1*1000) + 1000; fprintf('win_end= %d\n', win_end); 
        bout_end = [bout_end, win_end]; 
    end 
    %disp(bout_start); 
    %disp(bout_end);
   
    %disp(bout_start); 
    %disp(bout_end); 
    %%%crop out song bouts 
    fprintf("Cropping segments\n")
    if (length(bout_start)==length(bout_end))
        %disp(length(bout_start));
        i=2; 
        while i<=bout_count
            if bout_start(i) < bout_end(i-1)
                bout_count = bout_count - 1;
                bout_start(i) = []; 
                bout_end(i-1) = [];
            end 
            i = i + 1;
        end
        %disp(bout_start); 
        %disp(bout_end);
        fprintf('Found %d bouts. \n', bout_count); 
        for i = 1:bout_count
            first_syll = 0; 
            last_syll = 0; 
            new_onsets = []; 
            new_offsets = []; 
            %disp(bout_start ); 
            %disp(bout_end ); 
            for j = 1:length(not_data.onsets)
                if (not_data.onsets(j) > bout_start(i))
                    first_syll = j;
                    break;
                end 
            end 
            for j = length(not_data.offsets) : -1: 1
                if (not_data.offsets(j) < bout_end(i))
                    last_syll = j;
                    break;
                end 
            end 
            %disp(not_data.offsets);

            %disp(first_syll); 
            %disp(last_syll);
            crop_start = not_data.onsets(first_syll); 
            crop_end = not_data.offsets(last_syll); 
            syll_count = last_syll - first_syll + 1; 

            if syll_count < song_nb_syll
                disp('This bout has not reached the minimum size requirement'); 
            else
                %%%determine boundaries of crop segment 
                if (crop_start - 200 > 0 )
                    crop_start = crop_start - 200;
                else 
                    crop_start = 0; 
                end 
                if (crop_end + 200 <= length(audio_data)/fs*1000)
                    crop_end = crop_end + 200;
                else 
                    crop_end = length(audio_data)/fs*1000; 
                end 

                %%%eliminate half-syllables
                if (first_syll ~=1 && not_data.offsets(first_syll-1) > crop_start)
                    crop_start = not_data.offsets(first_syll - 1); 
                end 
                if (length(not_data.onsets)~=last_syll && not_data.onsets(last_syll + 1) < crop_end)
                    crop_end = not_data.onsets(last_syll + 1); 
                end 
                if (not_data.offsets(last_syll)/fs*1000 == length(audio_data))
                    crop_end = not_data.onsets(last_syll);
                end
           
                %%% find new onsets and offsets
            
                for j = first_syll : last_syll
                    new_onsets = [new_onsets, not_data.onsets(j) - crop_start];
                    new_offsets = [new_offsets, not_data.offsets(j) - crop_start]; 
                end 
                onsets = new_onsets(:);
                offsets = new_offsets(:); 

                %%%crop audio data
                crop_start = crop_start/1000 * fs + 1; 
                crop_end = crop_end/1000 * fs; 
                new_audio = audio_data(crop_start:crop_end); 
            
                if  ~ isempty(new_audio)
                

                    %%% save data
                    %disp(i);
                    new_wav_name = strcat(wav_file(1:end-4), '_seg_', string(i), '.wav'); 
                    disp (new_wav_name); 
                    new_wav_path = fullfile(out_dir, new_wav_name);
                    audiowrite(new_wav_path, new_audio, fs); 

                    new_mat_name = strcat(new_wav_name, '.not.mat'); 
                    new_mat_path = fullfile(out_dir, new_mat_name); 
            
                    fname = new_wav_path; 
                    labels = repmat('0', 1, length(onsets));
                    Fs = fs;
                    min_int = 5; 
                    min_dur = 20; 
                    threshold = 4.0000e-06;
                    sm_win = 2;

                    save(new_mat_path,'Fs', 'fname', 'labels', 'onsets', 'offsets', 'min_int', 'min_dur', 'threshold', 'sm_win');
                end 
            end 
        end 
    else 
        disp("Unequal number of bout starts and bout ends!!! Fix"); 
        fprintf("bout_count = %d, bout_start(length) = %d, bout_end length = %d\n", bout_count, length(bout_start), length(bout_end));
        disp (not_data.onsets);
        disp (not_data.offsets); 
        disp (bout_start); 
        disp (bout_end);
        disp (found_song); 
    end 
end 