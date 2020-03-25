#!/bin/bash

export MCRROOT=/usr/local/MATLAB/MATLAB_Runtime/v97
export LD_LIBRARY_PATH=${MCRROOT}/runtime/glnxa64:${MCRROOT}/bin/glnxa64:${MCRROOT}/sys/os/glnxa64:${MCRROOT}/sys/opengl/lib/glnxa64

xvfb-run --server-num=$(($$ + 99)) \
--server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
bash /extra/mavol/bin/run_mavol.sh ${MCRROOT} \
assr_label TESTPROJ-x-TESTSUBJ-x-TESTSESS-x-TESTSCAN-x-MultiAtlas_v2 \
seg_niigz /OUTPUTS/T1/orig_target_seg.nii.gz \
ticv_niigz /OUTPUTS/T1/TICV_output/orig_target_ticv.nii.gz \
vol_txt /OUTPUTS/T1/target_processed_label_volumes.txt \
out_dir /OUTPUTS
