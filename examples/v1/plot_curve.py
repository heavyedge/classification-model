import argparse
import pathlib

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def plot_calibration_curve(cv_files):
    methods = [path.stem.split(".")[1] for path in cv_files]
    dfs = [pd.read_csv(path) for path in cv_files]

    classes = pd.concat([df["class"] for df in dfs], axis=0).unique()
    n_classes = len(classes)
    nrows = int(np.ceil(n_classes / 3))
    ncols = min(n_classes, 3)

    fig, axes = plt.subplots(nrows, ncols, figsize=(10, 10))
    axes_flat = axes.flatten()

    colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]

    for i, class_name in enumerate(classes):
        ax = axes_flat[i]

        # Perfect calibration reference line
        ax.plot([0, 1], [0, 1], "k--", lw=0.75, label="Perfect")

        for j, (method, df) in enumerate(zip(methods, dfs)):
            sub_df = df[df["class"] == class_name]
            ax.plot(
                sub_df["mean_pred"],
                sub_df["frac_pos"],
                marker=".",
                color=colors[j % len(colors)],
                label=method,
            )

        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1.05)
        ax.set_title(class_name)
    fig.supxlabel("Mean predicted prob.")
    fig.supylabel("Fraction of positives")

    # Hide unused axes
    for k in range(n_classes, len(axes_flat)):
        axes_flat[k].set_visible(False)

    # Single shared legend in the last (empty) panel or below the figure
    if n_classes < len(axes_flat):
        legend_ax = axes_flat[n_classes]
        legend_ax.set_visible(True)
        legend_ax.axis("off")
        handles, labels = axes_flat[0].get_legend_handles_labels()
        legend_ax.legend(handles, labels, loc="center", frameon=False)
    else:
        handles, labels = axes_flat[0].get_legend_handles_labels()
        fig.legend(
            handles,
            labels,
            loc="lower center",
            ncol=len(methods) + 1,
            bbox_to_anchor=(0.5, -0.02),
            frameon=False,
        )
        fig.subplots_adjust(bottom=0.12)
    return fig


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot calibration curves.")
    parser.add_argument(
        "cv", type=pathlib.Path, nargs="*", help="Cross validation results"
    )
    parser.add_argument("-o", "--out", type=pathlib.Path, help="Output image file")
    args = parser.parse_args()
    fig = plot_calibration_curve(args.cv)
    if args.out:
        fig.savefig(args.out)
