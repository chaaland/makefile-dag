PYTHON=python
DATA_DIR=fake_data
FORECAST_DIR=forecasts
MODEL_DIR=models

DATA_SRC=data.py
FORECAST_SRC=forecast.py
TRAIN_SRC=modeling.py

DATA_EXE=$(PYTHON) $(DATA_SRC)
FORECAST_EXE=$(PYTHON) $(FORECAST_SRC)
TRAIN_EXE=$(PYTHON) $(TRAIN_SRC)

START=2000
END=2004