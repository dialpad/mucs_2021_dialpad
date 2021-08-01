#!/bin/bash

# Copyright 2021 Dialpad, Inc. (Shreekantha Nadig, Riqiang Wang)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <dst-dir>"
  echo "e.g.: $0 is21_challenge/"
  exit 1
fi

dst=$1
downloads=${dst}/downloads
data=${dst}/data
mkdir -p ${downloads} ${data}

wget https://azcopyvnext.azureedge.net/release20201211/azcopy_linux_amd64_10.8.0.tar.gz -O ${downloads}/azcopy_linux_amd64_10.8.0.tar.gz
tar -xf ${downloads}/azcopy_linux_amd64_10.8.0.tar.gz -C ${downloads}/

${downloads}/azcopy_linux_amd64_10.8.0/azcopy copy --recursive "${AZURE_DOWNLOAD_LINK}" ${downloads}/

for lang in Hindi Marathi Odia; do
    wget https://www.openslr.org/resources/103/${lang}_train.zip -O ${downloads}/${lang}_train.zip
    wget https://www.openslr.org/resources/103/${lang}_test.zip -O ${downloads}/${lang}_test.zip
done

mkdir -p ${downloads}/hindi ${downloads}/marathi ${downloads}/odia ${downloads}/gujarati ${downloads}/tamil ${downloads}/telugu

unzip -P "${Hindi_test_password}" ${downloads}/Hindi_test.zip -d ${downloads}/hindi/
tar -xf ${downloads}/hindi/Hindi_test.tar.gz -C ${downloads}/hindi/

unzip -P "${Hindi_train_password}" ${downloads}/Hindi_train.zip -d ${downloads}/hindi/
tar -xf ${downloads}/hindi/Hindi_train.tar.gz -C ${downloads}/hindi/

unzip -P "${Marathi_test_password}" ${downloads}/Marathi_test.zip -d ${downloads}/marathi/
tar -xf ${downloads}/marathi/Marathi_test.tar.gz -C ${downloads}/marathi/

unzip -P "${Marathi_train_password}" ${downloads}/Marathi_train.zip -d ${downloads}/marathi/
tar -xf ${downloads}/marathi/Marathi_train.tar.gz -C ${downloads}/marathi/

unzip -P "${Odia_test_password}" ${downloads}/Odia_test.zip -d ${downloads}/odia/
tar -xf ${downloads}/odia/Odia_test.tar.gz -C ${downloads}/odia/

unzip -P "${Odia_train_password}" ${downloads}/Odia_train.zip -d ${downloads}/odia/
tar -xf ${downloads}/odia/Odia_train.tar.gz -C ${downloads}/odia/
