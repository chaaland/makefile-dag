import argparse
import pickle
from pathlib import Path

import numpy as np
from sklearn.ensemble import GradientBoostingRegressor


def main(args: argparse.ArgumentParser) -> None:
    lr = 1e-3
    n_trees = 5
    param = {
        "n_estimators": n_trees,
        "learning_rate": lr,
    }

    model = GradientBoostingRegressor(**param)

    data_dir = Path(args.data_dir)
    data_files = [f for f in data_dir.glob("*.npy") if int(f.stem) < args.year]
    data = np.concatenate([np.load(f) for f in data_files], axis=0)
    X = data[:, :-1]
    y = data[:, -1]
    model.fit(X, y)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(exist_ok=True)
    model_file = output_dir / f"{str(args.year)}.pkl"
    with open(model_file, "wb") as f:
        pickle.dump(model, f)


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Create some training data")
    parser.add_argument("--data-dir", type=str, help="Folder in which the data lives")
    parser.add_argument("--output-dir", type=str, help="Folder in which the models will live")
    parser.add_argument("--year", type=int, help="The year for which the model will be used to forecast")
    args = parser.parse_args()

    main(args)
