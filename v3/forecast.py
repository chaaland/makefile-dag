import argparse
import pickle as pkl
from pathlib import Path

import numpy as np


def main(args: argparse.Namespace) -> None:
    data = np.load(Path(args.data_dir) / f"{args.year}.npy")

    model_file = Path(args.model_dir) / f"{args.year}.pkl"
    with open(model_file, "rb") as f:
        model = pkl.load(f)
    yhat = model.predict(data[:, :-1])

    output_dir = Path(args.output_dir)
    output_dir.mkdir(exist_ok=True)
    forecast_file = output_dir / f"{args.year}.npy"
    np.save(forecast_file, yhat)


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Create some training data")
    parser.add_argument("--year", type=int, help="The year to forecast")
    parser.add_argument("--data-dir", type=str, help="Path to the data")
    parser.add_argument("--output-dir", type=str, help="Path to the saved forecasts.")
    parser.add_argument("--model-dir", type=str, help="Path to the models")

    args = parser.parse_args()

    main(args)
