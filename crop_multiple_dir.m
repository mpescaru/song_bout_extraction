function crop_multiple_dir (input_parent, output_directory)
    subdirectories = dir (fullfile(input_parent)); 
    for i = 1:length(subdirectories)
        subdir_path = fullfile(input_parent, subdirectories(i).name);
        if (isfolder(subdir_path) && subdirectories(i).name(1) ~= '.')
            new_crop_dir = fullfile(output_directory, [subdirectories(i).name, '_cropped']);
            if (~isfolder(new_crop_dir))
                mkdir(new_crop_dir);
            end 
            subsubdirectories = dir(subdir_path);
            for j = 1:length(subsubdirectories)
                subsubdir_path = fullfile(subdir_path, subsubdirectories(j).name); 
                if (isfolder(subsubdir_path) && subsubdirectories(j).name(1)~='.')
                    new_crop_subdir = fullfile(new_crop_dir, [subsubdirectories(j).name, '_cropped']); 
                    if (~isfolder(new_crop_subdir))
                        mkdir(new_crop_subdir); 
                    end 
                    subsubsubdirs = dir(subsubdir_path); 
                    for k = 1:length(subsubsubdirs)
                        subsubsubdir_path = fullfile(subsubdir_path, subsubsubdirs(k).name); 
                        if (isfolder(subsubsubdir_path) && subsubsubdirs(k).name(1) ~= '.')
                            new_crop_subsubdir = fullfile(new_crop_subdir, subsubsubdirs(k).name); 
                            if (~isfolder(new_crop_subsubdir))
                                mkdir(new_crop_subsubdir);
                            end 
                            fprintf('Cropping songs for %s\n', subsubsubdir_path);
                            crop_songs_dir(subsubsubdir_path, new_crop_subsubdir, 0);
                        end 
                    end 
                end
            end 
        end 
    end 
end 
