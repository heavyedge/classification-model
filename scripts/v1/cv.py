import argparse
import csv
import logging
import os
import pathlib
import pickle

import numpy as np
from heavyedge import ProfileData
from heavyedge_classify.model import minirocket_classifier
from sklearn.model_selection import StratifiedKFold

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger(__name__)

N_SPLITS = int(os.getenv("HEAVYEDGE_N_SPLITS", 5))

parser = argparse.ArgumentParser()
parser.add_argument("profiles", type=pathlib.Path, help="Preprocessed profile data.")
parser.add_argument("labels", type=pathlib.Path, help="Label npy file")
parser.add_argument(
    "--calibration",
    choices=[
        "sigmoid",
        "isotonic",
        "temperature",
        "sigmoid_ovo",
        "isotonic_ovo",
    ],
    required=True,
    help="Calibration method",
)
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output pkl file")
args = parser.parse_args()

with ProfileData(args.profiles) as file:
    x = file.x()
    X, _, _ = file[:]
    X /= np.trapezoid(X, x, axis=1)[..., np.newaxis]

with open(args.labels, "r") as f:
    reader = csv.reader(f)
    # Burn first row as header
    next(reader)
    y = np.array([row[0] for row in reader])

n_classes = len(np.unique(y))

outer_fold = StratifiedKFold(n_splits=N_SPLITS, shuffle=True, random_state=0)
outer_splits = list(outer_fold.split(X, y))

log.info("Calibration method: %s", args.calibration)

models = []
y_prob_oof = np.full((len(y), n_classes), np.nan)

for fold_idx, (outer_train_idx, outer_test_idx) in enumerate(outer_splits):
    log.info(
        "  Outer fold %d/%d (train=%d, test=%d)",
        fold_idx + 1,
        N_SPLITS,
        len(outer_train_idx),
        len(outer_test_idx),
    )
    X_outer_train = X[outer_train_idx]
    y_outer_train = y[outer_train_idx]

    inner_fold = StratifiedKFold(n_splits=N_SPLITS, shuffle=True, random_state=42)
    inner_splits = list(inner_fold.split(X_outer_train, y_outer_train))

    model = minirocket_classifier(
        cv=inner_splits,
        calibration=args.calibration,
        verbose=True,
        random_state=42,
    )
    model.fit(X_outer_train, y_outer_train)

    y_prob_oof[outer_test_idx] = model.predict_proba(X[outer_test_idx])
    models.append(model)
    log.info("  Outer fold %d/%d done", fold_idx + 1, N_SPLITS)

log.info("Method %s complete", args.calibration)

with open(args.out, "wb") as f:
    pickle.dump(
        {
            "method": args.calibration,
            "outer_splits": outer_splits,
            "models": models,
            "y_prob_oof": y_prob_oof,
        },
        f,
    )
