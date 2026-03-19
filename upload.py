import os
from huggingface_hub import HfApi

api = HfApi(token=os.getenv("HUGGINGFACE_TOKEN"))

MODEL_VERSION = "0.0.1"

api.create_repo(
    repo_id="jeesoo9595/heavyedge-classify",
    repo_type="model",
    exist_ok=True,
)
api.upload_folder(
    folder_path="model",
    repo_id="jeesoo9595/heavyedge-classify",
    repo_type="model",
    commit_message=f"Upload model version {MODEL_VERSION}"
)
api.create_tag(
    repo_id="jeesoo9595/heavyedge-classify",
    tag=MODEL_VERSION,
)
