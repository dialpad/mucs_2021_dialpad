# Copyright 2021 Dialpad, Inc. (Shreekantha Nadig, Riqiang Wang)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)
python local/transliterate_text.py data/bengali_english_dev/text.orig "ben" data/bengali_english_dev/text_transliterated
python local/transliterate_text.py data/bengali_english_train/text.orig "ben" data/bengali_english_train/text_transliterated
python local/transliterate_text.py data/gujarati_dev/text.orig "guj" data/gujarati_dev/text_transliterated
python local/transliterate_text.py data/gujarati_train/text.orig "guj" data/gujarati_train/text_transliterated
python local/transliterate_text.py data/hindi_dev/text.orig "hin" data/hindi_dev/text_transliterated
python local/transliterate_text.py data/hindi_english_dev/text.orig "hin" data/hindi_english_dev/text_transliterated
python local/transliterate_text.py data/hindi_english_train/text.orig "hin" data/hindi_english_train/text_transliterated
python local/transliterate_text.py data/hindi_train/text.orig "hin" data/hindi_train/text_transliterated
python local/transliterate_text.py data/marathi_dev/text.orig "mar" data/marathi_dev/text_transliterated
python local/transliterate_text.py data/marathi_train/text.orig "mar" data/marathi_train/text_transliterated
python local/transliterate_text.py data/odia_dev/text.orig "ori" data/odia_dev/text_transliterated
python local/transliterate_text.py data/odia_train/text.orig "ori" data/odia_train/text_transliterated
python local/transliterate_text.py data/tamil_dev/text.orig "tam" data/tamil_dev/text_transliterated
python local/transliterate_text.py data/tamil_train/text.orig "tam" data/tamil_train/text_transliterated
python local/transliterate_text.py data/telugu_dev/text.orig "tel" data/telugu_dev/text_transliterated
python local/transliterate_text.py data/telugu_train/text.orig "tel" data/telugu_train/text_transliterated
