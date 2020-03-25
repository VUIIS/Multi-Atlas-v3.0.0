function mavol(varargin)

% We know:
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

% Parse inputs and report
P = inputParser;
addOptional(P,'assr_label','Unknown_assessor');
addOptional(P,'seg_niigz','/INPUTS/orig_target_seg.nii.gz');
addOptional(P,'ticv_niigz','');
addOptional(P,'vol_txt','/INPUTS/target_processed_label_volumes.txt');
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});

assr_label = P.Results.assr_label;
seg_niigz = P.Results.seg_niigz;
ticv_niigz = P.Results.ticv_niigz;
vol_txt = P.Results.vol_txt;
out_dir = P.Results.out_dir;

fprintf('assr_label: %s\n',assr_label);
fprintf('seg_niigz: %s\n',seg_niigz);
fprintf('ticv_niigz: %s\n',ticv_niigz);
fprintf('vol_txt: %s\n',vol_txt);
fprintf('out_dir: %s\n',out_dir);

% Copy SEG/TICV file to output location and unzip
copyfile(seg_niigz,fullfile(out_dir,'seg.nii.gz'));
system(['gunzip -f ' fullfile(out_dir,'seg.nii.gz')]);
seg_nii = fullfile(out_dir,'seg.nii');
if ~isempty(ticv_niigz)
	copyfile(ticv_niigz,fullfile(out_dir,'ticv.nii.gz'));
	system(['gunzip -f ' fullfile(out_dir,'ticv.nii.gz')]);
	ticv_nii = fullfile(out_dir,'ticv.nii');
else
	ticv_nii = '';
end

% Get pixdim with NIfTI_20140122
n_affected = load_nii(seg_nii,[],[],[],[],[],1);
pixdim_affected = n_affected.hdr.dime.pixdim(2:4);
voxvol_affected = prod(pixdim_affected);

% Get pixdim with niftiread
n_true = niftiinfo(seg_nii);
pixdim_true = n_true.PixelDimensions;
voxvol_true = prod(pixdim_true);

% Compute the possible error due to bug in load_nii
vol_pcterror = 100 * (voxvol_affected-voxvol_true) / voxvol_true;

% Load the erroneous vol_txt to get ROI list
rois = readtable(vol_txt,'Delimiter','comma','Format','%s%s%f');

% Fix the format of labels to be machine readable and numeric
rois.label = strrep( ...
	rois.LabelNumber_BrainCOLOR_, '208+209','208 209');
rois.label = cellfun( ...
	@str2num, rois.label, 'UniformOutput',false);

% Fix the region names too
rois.name = cellfun(@(x) strrep(x,' ','_'),rois.LabelName_BrainCOLOR_, ...
	'UniformOutput',false);
rois.name = cellfun(@lower,rois.name,'UniformOutput',false);
rois.name = cellfun(@matlab.lang.makeValidName,rois.name,'UniformOutput',false);

% Load the SEG and TICV image
seg = niftiread(seg_nii);
if ~isempty(ticv_nii)
	ticv = niftiread(ticv_nii);
else
	ticv = [];
end

% Compute volumes and write to output file. For TICV regions use the TICV
% file. Compute the error we actually observed in the data by estimating it
% from a large white matter ROI.
results = table(vol_pcterror,nan, ...
	'VariableNames',{'load_nii_possible_pcterror','load_nii_observed_pcterror'});
for r = 1:height(rois)
	if strcmp(rois.name{r},'posteriorfossa') | ...
			strcmp(rois.name{r},'ticv')
		fprintf('Found TICV ROI %s\n',rois.name{r});
		if isempty(ticv)
			error('Found a TICV region but no TICV image')
		end
		voxels = sum( ismember(ticv(:),rois.label{r}) );
		results.([rois.name{r} '_mm3']) = voxels * voxvol_true;
	else
		voxels = sum( ismember(seg(:),rois.label{r}) );
		results.([rois.name{r} '_mm3']) = voxels * voxvol_true;
	end
end
wm_true = results.right_cerebellum_white_matter_mm3;
wm_observed = rois.LabelVolume_mm_3_( ...
	strcmp(rois.name,'right_cerebellum_white_matter'));
results.load_nii_observed_pcterror(1) = 100 * (wm_observed-wm_true) / wm_true;
writetable(results,fullfile(out_dir,'stats.csv'));

% Make PDF
pdf_figure = openfig('mavol_pdf.fig','new');
figH = guihandles(pdf_figure);
set(figH.assr_info, 'String', assr_label);
set(figH.date,'String',['Report date: ' date]);
set(figH.version,'String',['Matlab version: ' version]);
info = table(results{:,3:end}.', ...
	'RowNames',results.Properties.VariableNames(3:end), ...
	'VariableNames',{'Volume_mm3'});
istr = evalc('disp(info)');
istr = strrep(istr,'<strong>','');
istr = strrep(istr,'</strong>','');
istr = [ ...
	sprintf(['Possible error for this image geometry: %0.4f%%\n' ...
	'Actual error in the analyzed MultiAtlas: %0.4f%%\n\n' ...
	'First few corrected volumes:\n\n'],vol_pcterror, ...
	results.load_nii_observed_pcterror) ...
	istr ];
set(figH.results_text, 'String', istr)
print(pdf_figure,'-dpdf',fullfile(out_dir,'mavol.pdf'))
close(pdf_figure)

% Exit if we're compiled
if isdeployed
	exit(0)
end

