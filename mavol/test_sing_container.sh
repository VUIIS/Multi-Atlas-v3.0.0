#!/bin/bash

singularity run \
--cleanenv \
--home `pwd`/INPUTS1 \
--bind INPUTS1:/INPUTS1 \
--bind OUTPUTS1:/OUTPUTS1 \
mavol-v1.0.0.simg \
assr_label TESTPROJ-x-TESTSUBJ-x-TESTSESS-x-TESTSCAN-x-MultiAtlas \
seg_niigz /INPUTS1/orig_target_seg.nii.gz \
vol_txt /INPUTS1/target_processed_label_volumes.txt \
out_dir /OUTPUTS1



singularity run \
--cleanenv \
--home `pwd`/INPUTS2 \
--bind INPUTS2:/INPUTS2 \
--bind OUTPUTS2:/OUTPUTS2 \
mavol-v1.0.0.simg \
assr_label TESTPROJ-x-TESTSUBJ-x-TESTSESS-x-TESTSCAN-x-MultiAtlas_v2 \
seg_niigz /INPUTS2/orig_target_seg.nii.gz \
ticv_niigz /INPUTS2/orig_target_ticv.nii.gz \
vol_txt /INPUTS2/target_processed_label_volumes.txt \
out_dir /OUTPUTS2
