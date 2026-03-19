# Train HeavyEdge-Classify

Repository to train [HeavyEdge-Classify](https://pypi.org/project/heavyedge-classify/) model and upload to HuggingFace.

## Setup

```
pip install gdown
gdown --fuzzy [google drive link] -O dataset.tar
pip install -r requirements.txt
```

## Preprocessing

```
mkdir -p _data
tar -xf dataset.tar -C _data
make
```

## Training model and testing

```
./train.sh
./test.sh
```

## Upload to HuggingFace

```
pip install huggingface_hub
python3 upload.py
```
