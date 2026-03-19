import argparse
import pathlib

import numpy as np
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("knees", type=pathlib.Path, help="Knee labels.")
parser.add_argument("canonical", type=pathlib.Path, help="Canonical labels.")
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output npy file")
args = parser.parse_args()


def combine_labels(knees, canonical):
    canonical = canonical.astype(bool)
    out = np.empty_like(knees)
    out[knees == 0] = 0
    out[(knees == 1) & canonical] = 1
    out[(knees == 1) & (~canonical)] = 2
    out[(knees == 2) & canonical] = 3
    out[(knees == 2) & (~canonical)] = 4
    out[(knees == 3) & canonical] = 5
    out[(knees == 3) & (~canonical)] = 6
    return out


knees = pd.read_csv(args.knees)["Type"].to_numpy()
canonical = pd.read_csv(args.canonical)["Type"].to_numpy()
np.save(args.out, combine_labels(knees, canonical))
