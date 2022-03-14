import argparse
import datetime
from pathlib import Path

import numpy as np


def make_data(n: int, c: int) -> np.ndarray:
    data = np.random.randn(n, c).astype(np.float32)
    return data


def write_data(fpath: Path, x: np.ndarray) -> None:
    np.save(fpath, x, allow_pickle=False)


def main(args: argparse.Namespace) -> None:
    start_date = datetime.datetime.strptime(args.start, "%Y-%m-%d")
    end_date = datetime.datetime.strptime(args.end, "%Y-%m-%d")
    output_dir = Path(args.output_dir)

    n_days = (end_date - start_date).days
    n_channels = 100
    data = make_data(n_days, n_channels)

    output_dir.mkdir(exist_ok=True, parents=True)
    out_file = Path(args.output_dir) / f"{start_date.year}"

    write_data(out_file, data)


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Create some training data")
    parser.add_argument("--start", type=str, help="The start of the data in YYYYmmDD formt")
    parser.add_argument("--end", type=str, help="The end of the data in YYYYmmDD formt")
    parser.add_argument("--output-dir", type=str, help="The directory in which to put the data")

    args = parser.parse_args()

    main(args)
