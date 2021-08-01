# Copyright 2021 Dialpad, Inc. (Shreekantha Nadig, Riqiang Wang)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)
# Add an explicit LID token to the beginning of each text entry

CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 run.pl --gpu 8 exp/train_enc_dec_joint_c0/train.log \
    asr_train.py \
    --config conf/train_enc_dec.yaml \
    --preprocess-conf conf/specaug.yaml \
    --ngpu 8 \
    --backend "pytorch" \
    --outdir exp/train_enc_dec_joint_c0 \
    --tensorboard-dir tensorboard/train_enc_dec_joint_c0 \
    --debugmode 4 \
    --dict is21_challenge/data/task1/train_combined_lid/lang_char/train_combined_char1_units.txt \
    --debugdir exp/train_enc_dec_joint_c0 \
    --verbose 2 \
    --train-json is21_challenge/dump/task1/lid/train_combined/data_char1.json \
    --valid-json is21_challenge/dump/task1/lid/dev_combined/data_char1.json
