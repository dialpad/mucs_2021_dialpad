# The Dialpad ASR System for the Multilingual ASR Challenge for Low Resource Indian Languages 2021
### Shreekantha Nadig, Riqiang Wang, Wang Yau Li, Jeffrey Michael, Frédéric Mailhot, Simon Vandieken, Jonas Robertson
#### Dialpad, Inc.

This paper describes the multilingual ASR systems developed at Dialpad, Inc. for the Multilingual ASR challenge for low resource Indian languages at Interspeech 2021. We participated in Sub-task 1, where the systems are trained on data of six Indic languages provided by the organizers. On this task, we experimented with both hybrid HMM-DNN and end-to-end ASR architectures and studied how fine-tuning techniques can help in this multilingual scenario. We also experimented with both multilingual and language-specific decoders by using a pre-trained encoder, as well as the use of appropriate RNN and n-gram language models. Furthermore, we present novel studies on transliteration-based pre-training of the encoder, and a joint LID and ASR architecture. We show that the multilingual end-to-end ASR models outperform both hybrid model and monolingual baselines. Also, we demonstrate that current methods of joint LID-ASR fail when there are confounding channel characteristics. We conducted studies and propose ideas on how to mitigate the effect of some of the channel characteristics on the task of language recognition. Our best submission to the challenge achieved an average WER of $22.95\%$ on the development set and $31.87\%$ on the held-out test set and contains language-specific decoders fine-tuned on the multilingual encoder, along with the use of language-specific RNNLMs and n-gram LMs.


## Video Presentation

[![Dialpad video presentation for MUCS 2021 workshop](https://img.youtube.com/vi/_ZGWXh3UMiI/0.jpg)](https://youtu.be/_ZGWXh3UMiI)

## Models
All the end-to-end models in this work are trained using the ESPnet toolkit. Hence, the inference also follows the standard format of the toolkit.
The features are extracted using `torchaudio` (as opposed to `kaldi` binaries) in the toolkit. We provide the feature extraction code as well.
All of the models in this work can be used with the standard ESPnet decoding scripts as mentioned in the ESPnet toolkit: https://github.com/espnet/interspeech2019-tutorial

We make available the following pre-trained models for this work:

| Name      | Description |
| ----------- | ----------- |
| B0      | Baseline encoder-decoder with combined vocabulary |
| B1   | B0's encoder + monolingual decoder (Encoder frozen from B0) |
| B1 (unfreeze)   | B0's encoder + monolingual decoder (Fine-tune after un-freezing Encoder) |
| B3   | B0 but with transliterated latin script |
| C0   | B0 + explicit LID subtask |
| C1   | B3's encoder + explicit LID decoder |
| L0   | LID trained from scratch |
| L1   | LID with transliterated Encoder from B3 |
| "lang"\_RNNLM | Byte-level RNNLM for each language |

You can find the pre-trained models in this Google Drive link: https://drive.google.com/drive/folders/1QlEZgzscznfPaVv_B62Ipz0grXdeDNIr?usp=sharing

## Extracting features for inference
For all experiments, we extracted 80-dimensional log Mel filterbank features with a window size of 25 ms computed at every 10 ms.
The features are extracted using `torchaudio.compliance.kaldi.fbank`
```python
lmspc = torchaudio.compliance.kaldi.fbank(
            waveform=torch.unsqueeze(torch.tensor(signal), axis=0),
            sample_frequency=8000,
            dither=1e-32,
            energy_floor=0,
            num_mel_bins=80,
        )
```

## Performing inference with the pre-trained models
We give an example ipython notebook (`inference_example.ipynb`) to perform inference with various models with features extracted using `torchaudio` and with an appropriate RNNLM.
