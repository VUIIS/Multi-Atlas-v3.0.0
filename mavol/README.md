# Corrected computation of multi-atlas regional volumes

Some versions of the multi-atlas segmentation pipeline labeled `Multi_Atlas` and `Multi_Atlas_v2` were affected by a bug in a toolbox. The regional volumes reported in the `VOL_TXT/target_processed_label_volumes.txt` file were slightly underestimated in many cases.

The code here loads the multi-atlas segmentation result images (`SEG/orig_target_seg.nii.gz`, and `TICV/orig_target_ticv.nii.gz` if available) and computes correct regional volumes. It also reports the size of the error in the original output.

The bug is in the 20140122 (latest) version of this Matlab Nifti toolbox: https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

The `load_nii` function returns incorrect values for the pixdim fields of the Nifti header. The related functions `load_nii_hdr` and `load_untouch_nii` return the correct values for the pixdim fields.

As an alternative for the Matlab Nifti toolbox, newer versions of matlab have `niftiread`, `niftiinfo`, and `niftiwrite` functions. Another possibility is SPM12, which provides tools for reading and writing Nifti files.
