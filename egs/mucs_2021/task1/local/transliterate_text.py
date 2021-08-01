# Copyright 2021 Dialpad, Inc. (Shreekantha Nadig, Riqiang Wang)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

import sys
from indictrans import Transliterator
from tqdm import tqdm
import multiprocess as mp

SRC_FILE = sys.argv[1]
SRC_LANG = sys.argv[2]
DST_FILE = sys.argv[3]

NJ = mp.cpu_count()
pool = mp.Pool(processes=NJ)

transliteration_model = Transliterator(source=SRC_LANG, target='eng', rb=True)

uttids = []
prompts = []
with open(SRC_FILE, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip().split()
        uttids.append(line[0])
        prompts.append(' '.join(line[1:]))

def transliterate(args):
    transliteration_model, sentence = args
    return transliteration_model.transform(sentence)

transliterated_prompts = pool.map(transliterate, \
                    tqdm([(transliteration_model, row) for row in prompts]))


with open(DST_FILE, 'w', encoding='utf-8') as f:
    for uttid, prompt in zip(uttids, transliterated_prompts):
        prompt = ' '.join([char for char in '_'.join([word for word in prompt.split()])])
        prompt = prompt.lower().replace('_', '<w>')
        f.write(f"{uttid} {prompt}\n")
