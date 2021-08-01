#!/bin/bash

# Copyright 2021 Dialpad, Inc. (Shreekantha Nadig, Riqiang Wang)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <src-dir> <dst-dir> <audio-dir-name>"
  echo "e.g.: $0 downloads/hindi/train/ data/hindi/train/ Audios"
  exit 1
fi

src=$1
dst=$2
audio_dir=$3

if ! which sox >&/dev/null; then
   echo "Please install 'sox' on ALL worker nodes!"
   exit 1
fi

mkdir -p ${dst}
cp ${src}/transcription.txt ${dst}/text.orig

sed -i "s/\.//g" ${dst}/text.orig
sed -i "s/,//g" ${dst}/text.orig
sed -i "s/?//g" ${dst}/text.orig

cat ${dst}/text.orig | awk '{print $1}' > ${dst}/uttids
for i in `cat ${dst}/uttids`; do echo "sox ${src}/${audio_dir}/${i}.wav -t wav -r 8000 -b 16 - |" >> ${dst}/wav_cmd; done;
paste ${dst}/uttids ${dst}/wav_cmd > ${dst}/wav.scp
paste ${dst}/uttids ${dst}/uttids > ${dst}/utt2spk
utils/utt2spk_to_spk2utt.pl ${dst}/utt2spk > ${dst}/spk2utt

python3 local/get_valid_utts.py ${dst}/text.orig ${dst}/text
utils/fix_data_dir.sh $dst || exit 1
utils/validate_data_dir.sh --no-feats $dst || exit 1

echo "$0: successfully prepared data in $dst"

exit 0
