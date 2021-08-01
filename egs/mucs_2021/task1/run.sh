#!/bin/bash

# Copyright 2021 Dialpad, Inc. (Shreekantha Nadig, Riqiang Wang)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

# general configuration
backend=pytorch
stage=-1       # start from -1 if you need to start from data download
stop_stage=100
ngpu=1         # number of gpus ("0" uses cpu, otherwise use gpu)
debugmode=1
task_dir=is21_challenge
dumpdir=${task_dir}/dump   # directory to dump full features
N=0            # number of minibatches to be used (mainly for debugging). "0" uses all minibatches.
verbose=1      # verbose option
resume=        # Resume the training from snapshot

# feature configuration
do_delta=false

train_config=conf/train_enc_dec.yaml
decode_config=conf/decode.yaml

# decoding parameter
recog_model=model.acc.best # set a model to be used for decoding: 'model.acc.best' or 'model.loss.best'

# data
downloads_dir=${task_dir}/downloads
data_dir=${task_dir}/data
trans_type=char

# bpemode (unigram or bpe)
nbpe=1
bpemode=char

# exp tag
tag="" # tag for managing experiments.

. utils/parse_options.sh || exit 1;

# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',
set -e
set -u
set -o pipefail

train_set=train_combined
train_dev=dev_combined
recog_set="gujarati-dev hindi-dev marathi-dev odia-dev tamil-dev telugu-dev"

if [ ${stage} -le -1 ] && [ ${stop_stage} -ge -1 ]; then
    echo "stage -1: Downloading and extracting data. This is going to take a while."
    local/download_and_untar.sh ${task_dir} || exit 1
fi

if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
    echo "stage 0: Preparing data directories"

    for lang in hindi marathi odia; do
        echo "Preparing data for ${lang} language"
        local/data_prep_task1.sh ${task_dir}/downloads/${lang}/train ${task_dir}/data/${lang}/train audio
        utils/fix_data_dir.sh ${task_dir}/data/${lang}/train
        local/data_prep_task1.sh ${task_dir}/downloads/${lang}/test ${task_dir}/data/${lang}/dev audio
        utils/fix_data_dir.sh ${task_dir}/data/${lang}/dev
    done

    for lang in ta te gu; do
        echo "Preparing data for ${lang} language"
        local/data_prep_task1.sh ${task_dir}/downloads/microsoftspeechcorpusindianlanguages/${lang}-in-Train/ ${task_dir}/data/${lang}/train Audios
        utils/fix_data_dir.sh ${task_dir}/data/${lang}/train
        local/data_prep_task1.sh ${task_dir}/downloads/microsoftspeechcorpusindianlanguages/${lang}-in-Test/ ${task_dir}/data/${lang}/dev Audios
        utils/fix_data_dir.sh ${task_dir}/data/${lang}/dev
    done

    utils/copy_data_dir.sh --spk-prefix "hindi_" --utt-prefix "hindi_" is21_challenge/data/hindi/train/ is21_challenge/data/task1/hindi/train/
    utils/copy_data_dir.sh --spk-prefix "hindi_" --utt-prefix "hindi_" is21_challenge/data/hindi/dev/ is21_challenge/data/task1/hindi/dev/

    utils/copy_data_dir.sh --spk-prefix "marathi_" --utt-prefix "marathi_" is21_challenge/data/marathi/train/ is21_challenge/data/task1/marathi/train/
    utils/copy_data_dir.sh --spk-prefix "marathi_" --utt-prefix "marathi_" is21_challenge/data/marathi/dev/ is21_challenge/data/task1/marathi/dev/

    utils/copy_data_dir.sh --spk-prefix "odia_" --utt-prefix "odia_" is21_challenge/data/odia/train/ is21_challenge/data/task1/odia/train/
    utils/copy_data_dir.sh --spk-prefix "odia_" --utt-prefix "odia_" is21_challenge/data/odia/dev/ is21_challenge/data/task1/odia/dev/

    utils/copy_data_dir.sh --spk-prefix "tamil_" --utt-prefix "tamil_" is21_challenge/data/ta/train/ is21_challenge/data/task1/tamil/train/
    utils/copy_data_dir.sh --spk-prefix "tamil_" --utt-prefix "tamil_" is21_challenge/data/ta/dev/ is21_challenge/data/task1/tamil/dev/

    utils/copy_data_dir.sh --spk-prefix "telugu_" --utt-prefix "telugu_" is21_challenge/data/te/train/ is21_challenge/data/task1/telugu/train/
    utils/copy_data_dir.sh --spk-prefix "telugu_" --utt-prefix "telugu_" is21_challenge/data/te/dev/ is21_challenge/data/task1/telugu/dev/

    utils/copy_data_dir.sh --spk-prefix "gujarati_" --utt-prefix "gujarati_" is21_challenge/data/gu/train/ is21_challenge/data/task1/gujarati/train/
    utils/copy_data_dir.sh --spk-prefix "gujarati_" --utt-prefix "gujarati_" is21_challenge/data/gu/dev/ is21_challenge/data/task1/gujarati/dev/

    utils/data/perturb_data_dir_speed.sh 0.9 is21_challenge/data/task1/telugu/train/ is21_challenge/data/task1/telugu_sp09/train/
    utils/data/perturb_data_dir_speed.sh 0.9 is21_challenge/data/task1/tamil/train/ is21_challenge/data/task1/tamil_sp09/train/
    utils/data/perturb_data_dir_speed.sh 0.9 is21_challenge/data/task1/gujarati/train/ is21_challenge/data/task1/gujarati_sp09/train/
fi

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    echo "stage 1: Extract features"

    for lang in gujarati gujarati_sp09 hindi marathi odia tamil tamil_sp09 telugu telugu_sp09; do
        make_fbank_torchaudio.sh --out_scp "feats_default.scp" --cmd "run.pl" --nj 80 --fs 8000 --n_mels 80 \
        is21_challenge/data/task1/${lang}/train/ is21_challenge/dump_feats/default/task1/${lang}/train/ \
        is21_challenge/feats/default/task1/${lang}/train/

        make_fbank_torchaudio.sh --out_scp "feats_default.scp" --cmd "run.pl" --nj 80 --fs 8000 --n_mels 80 \
        is21_challenge/data/task1/${lang}/dev/ is21_challenge/dump_feats/default/task1/${lang}/dev/ \
        is21_challenge/feats/default/task1/${lang}/dev/
    done

    utils/combine_data.sh --extra-files "feats_default.scp" \
        is21_challenge/data/task1/train_combined is21_challenge/data/task1/gujarati/train/ \
        is21_challenge/data/task1/gujarati_sp09/train/ is21_challenge/data/task1/hindi/train/ \
        is21_challenge/data/task1/odia/train/ is21_challenge/data/task1/marathi/train/ \
        is21_challenge/data/task1/tamil/train/ is21_challenge/data/task1/tamil_sp09/train/ \
        is21_challenge/data/task1/telugu/train/ is21_challenge/data/task1/telugu_sp09/train/

    utils/fix_data_dir.sh is21_challenge/data/task1/train_combined/

    utils/combine_data.sh --extra-files "feats_default.scp" \
        is21_challenge/data/task1/dev_combined is21_challenge/data/task1/gujarati/dev/ \
        is21_challenge/data/task1/hindi/dev/ is21_challenge/data/task1/odia/dev/ \
        is21_challenge/data/task1/marathi/dev/ is21_challenge/data/task1/tamil/dev/ \
        is21_challenge/data/task1/telugu/dev/

    utils/fix_data_dir.sh is21_challenge/data/task1/dev_combined/

    compute-cmvn-stats scp:is21_challenge/data/task1/train_combined/feats_default.scp is21_challenge/data/task1/train_combined/cmvn_default.ark
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    echo "stage 2: Apply CMVN and dump features"

    dump.sh --cmd "$train_cmd" --nj 80 --do_delta ${do_delta} \
        is21_challenge/data/task1/train_combined/feats_default.scp \
        is21_challenge/data/task1/train_combined/cmvn_default.ark \
        is21_challenge/dump_feats_final_logs/task1/default/train_combined \
        is21_challenge/dump/task1/default/train_combined

    dump.sh --cmd "$train_cmd" --nj 80 --do_delta ${do_delta} \
        is21_challenge/data/task1/dev_combined/feats_default.scp \
        is21_challenge/data/task1/train_combined/cmvn_default.ark \
        is21_challenge/dump_feats_final_logs/task1/default/dev_combined \
        is21_challenge/dump/task1/default/dev_combined

fi

dict=is21_challenge/data/task1/train_combined/lang_char/${train_set}_${bpemode}${nbpe}_units.txt
bpemodel=is21_challenge/data/task1/train_combined/lang_char/${train_set}_${bpemode}${nbpe}
if [ ${stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then
    echo "stage 3: Dictionary and Json Data Preparation"

    mkdir -p is21_challenge/data/task1/train_combined/lang_char
    echo "<unk> 1" > ${dict} # <unk> must be 1, 0 will be used for "blank" in CTC
    cut -f 2- -d" " is21_challenge/data/task1/train_combined/text > is21_challenge/data/task1/train_combined/lang_char/input.txt

    spm_train --character_coverage=1.0 \
    --input=is21_challenge/data/task1/train_combined/lang_char/input.txt \
    --model_type=${bpemode} --model_prefix=${bpemodel}

    spm_encode --model=${bpemodel}.model --output_format=piece \
    < is21_challenge/data/task1/train_combined/lang_char/input.txt \
    | tr ' ' '\n' | sort | uniq | awk '{print $0 " " NR+1}' >> ${dict}

    wc -l ${dict}

    # make json labels
    for dataset in train dev; do
        data2json.sh --nj 80 \
        --feat is21_challenge/dump/task1/default/${dataset}_combined/feats.scp \
        --bpecode ${bpemodel}.model is21_challenge/data/task1/${dataset}_combined \
        ${dict} > is21_challenge/dump/task1/default/${dataset}_combined/data_${bpemode}${nbpe}.json
    done

fi
