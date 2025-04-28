# song_bout_extraction
MATLAB scripts to extract song bouts from segmented files 

Can be used on manual (evsonganaly) segmentations or automatic WhisperSeg segmented directories. 
Usage: 
1. download directory of scrips
2. for a single directory, use
   ```MATLAB
   >> crop_songs_dir('\PATH\TO\INPUT_DIRECTORY' , 'PATH\TO\OUTPUT_DIRECTORY', MAT_ANNOTATION_FLAG)
   ```
   where MAT_ANNOTATION_FLAG is a boolean. If folder alredy contains .not.mat evsonganaly segmentations, set the flag to 1:
```MATLAB
   >> crop_songs_dir(path\to\input, path\t\outputdir, 1)
```
   otherwise set to 0
```MATLAB
    >> crop_songs_dir(path\to\input, path\to\output, 0)
```
4. for multiple nested directories, structured as: parent_folder -> batch (birds from tutor x) -> birds ->  timepoints
```MATLAB
   >> crop_multiple_dir('PATH\TO\PARENT_DIRECTORY', 'PATH\TO\OUTPUT')
```
   This script assumes segmentations are given in WhisperSeg format (csv file in a fiolder called Segmentations for each timepoint).
   To modify it such that it uses evsonganaly segmentations to determine where song bouts are, change line 27 to
```MATLAB
   >> crop_songs_dir(subsubsubdir_path, new_crop_subsubdir, 1); (i. e. change flag to 1)
```
 
