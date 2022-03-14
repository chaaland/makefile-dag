# In the beginning...there was `make`

Whole plethora of DAG runners these days

    - Airflow
    - Azkaban
    - d6tflow
    - Dagster
    - Dask
    - Doit
    - Kubeflow
    - Luigi
    - Oozie
    - Prefect
    - SCons
    - Snakemake

The `make` utility function was created in the 1970s by an intern at Bell Labs. One of the original `luigi` [presentations](https://www.slideshare.net/erikbern/luigi-presentation-nyc-data-science) cites `make` as the inspiration for the library interface.

A common misconception is that `make` is a build tool for C/C++. It is that. But it's also much more general. It can be used for orchestraing arbitrary DAGs.

## V1
Show picture of DAG we're trying to build
Make entire DAG with a makefile, explain concept of targets, actions, dependencies and compare with Luigi vocab (task, run, requires)

Below is a Makefile for constructing the DAG
```
# pull data
fake_data/2000.npy : 
	python data.py --start "2000-01-01" --end "2000-12-31" --output-dir fake_data

fake_data/2001.npy :
	python data.py --start "2001-01-01" --end "2001-12-31" --output-dir fake_data

fake_data/2002.npy :
	python data.py --start "2002-01-01" --end "2002-12-31" --output-dir fake_data

fake_data/2003.npy :
	python data.py --start "2003-01-01" --end "2003-12-31" --output-dir fake_data

fake_data/2004.npy :
	python data.py --start "2004-01-01" --end "2004-12-31" --output-dir fake_data

# fit models
models/2001.pkl : fake_data/2000.npy
	python modeling.py --year 2001 --data-dir fake_data --output-dir models

models/2002.pkl : fake_data/2001.npy fake_data/2000.npy
	python modeling.py --year 2002 --data-dir fake_data --output-dir models

models/2003.pkl : fake_data/2002.npy fake_data/2001.npy fake_data/2000.npy
	python modeling.py --year 2003 --data-dir fake_data --output-dir models

models/2004.pkl : fake_data/2003.npy fake_data/2002.npy fake_data/2001.npy fake_data/2000.npy
	python modeling.py --year 2004 --data-dir fake_data --output-dir models

# forecast models
forecasts/2001.npy : models/2001.pkl fake_data/2001.npy
	python forecast.py --year 2001 --data-dir fake_data --model-dir models --output-dir forecasts

forecasts/2002.npy : models/2002.pkl fake_data/2002.npy
	python forecast.py --year 2002 --data-dir fake_data --model-dir models --output-dir forecasts

forecasts/2003.npy : models/2003.pkl fake_data/2003.npy
	python forecast.py --year 2003 --data-dir fake_data --model-dir models --output-dir forecasts

forecasts/2004.npy : models/2004.pkl fake_data/2004.npy 
	python forecast.py --year 2004 --data-dir fake_data --model-dir models --output-dir forecasts
```

Each component of the Makefile is of the form
```
<target> : <dependency_1> <dependency_2>
    <action>
```

A *target* is the file to be created or built. This is the equivalent of the `output()` method in luigi.

To the right of the colon are the dependencies. This is equivalent of the `requires()` method in luigi.

The *action* is indented on the line below. This is equivalent of the `run()` method in luigi.

Running `make forecasts/2003.npy`, for example, will create model data from 2000 to 2003, build a model trained on years 2000, 2001, and 2002, then make forecasts for 2003.

Explain downsides

    - what happens if code changes
    - heavy redundancy
    - make by default just runs the first target

## V2
By default running `make` without arguments will just execute the first target. Equivalent to running 

```make fake_data/2000.npy```

We can introduce a target `all` so that we don't have to run `make` on every single target. Unlike the other targets, this doesn't correspond to a file to be created so it's given a special *phony* designation.

`clean` is another common target to have in a Makefile to force a fresh run of the DAG by removing all completed targets. Similar to `all`, it is a phony target in the sense that it doesn't correspond to an actual built artifact.

```
.PHONY : all clean

all: forecasts/2001.npy forecasts/2002.npy forecasts/2003.npy forecasts/2004.npy

clean : 
	rm -rf models/ forecasts/ fake_data/


# pull data
fake_data/2000.npy : 
	python data.py --start "2000-01-01" --end "2000-12-31" --output-dir fake_data

fake_data/2001.npy :
	python data.py --start "2001-01-01" --end "2001-12-31" --output-dir fake_data

fake_data/2002.npy :
	python data.py --start "2002-01-01" --end "2002-12-31" --output-dir fake_data

fake_data/2003.npy :
	python data.py --start "2003-01-01" --end "2003-12-31" --output-dir fake_data

fake_data/2004.npy :
	python data.py --start "2004-01-01" --end "2004-12-31" --output-dir fake_data

# fit models
models/2001.pkl : fake_data/2000.npy
	python modeling.py --year 2001 --data-dir fake_data --output-dir models

models/2002.pkl : fake_data/2001.npy fake_data/2000.npy
	python modeling.py --year 2002 --data-dir fake_data --output-dir models

models/2003.pkl : fake_data/2002.npy fake_data/2001.npy fake_data/2000.npy
	python modeling.py --year 2003 --data-dir fake_data --output-dir models

models/2004.pkl : fake_data/2003.npy fake_data/2002.npy fake_data/2001.npy fake_data/2000.npy
	python modeling.py --year 2004 --data-dir fake_data --output-dir models

# forecast models
forecasts/2001.npy : models/2001.pkl fake_data/2001.npy
	python forecast.py --year 2001 --data-dir fake_data --model-dir models --output-dir forecasts

forecasts/2002.npy : models/2002.pkl fake_data/2002.npy
	python forecast.py --year 2002 --data-dir fake_data --model-dir models --output-dir forecasts

forecasts/2003.npy : models/2003.pkl fake_data/2003.npy
	python forecast.py --year 2003 --data-dir fake_data --model-dir models --output-dir forecasts

forecasts/2004.npy : models/2004.pkl fake_data/2004.npy 
	python forecast.py --year 2004 --data-dir fake_data --model-dir models --output-dir forecasts
```

Explain the use of phony targets that don't correspond to actual files

## V3
We can use variables to remove some of the hardcoded constants that appear in the Makefile. Currently, in the event we want to change the output directory of the forecasts, we have to make the change several places.

```
PYTHON=python
DATA_DIR=fake_data
FORECAST_DIR=forecasts
MODEL_DIR=models

DATA_EXE=$(PYTHON) data.py
FORECAST_EXE=$(PYTHON) forecast.py
TRAIN_EXE=$(PYTHON) modeling.py

.PHONY : all clean variables

all: $(FORECAST_DIR)/2001.npy $(FORECAST_DIR)/2002.npy $(FORECAST_DIR)/2003.npy $(FORECAST_DIR)/2004.npy

clean : 
	rm -rf $(MODEL_DIR)/ $(FORECAST_DIR)/ $(DATA_DIR)/

# print defined variables
variables :
	@echo DATA_EXE: $(DATA_EXE)
	@echo TRAIN_EXE: $(TRAIN_EXE)
	@echo FORECAST_EXE: $(FORCAST_EXE)

# pull data
$(DATA_DIR)/2000.npy : 
	$(DATA_EXE) --start "2000-01-01" --end "2000-12-31" --output-dir $(DATA_DIR)

$(DATA_DIR)/2001.npy :
	$(DATA_EXE) --start "2001-01-01" --end "2001-12-31" --output-dir $(DATA_DIR)

$(DATA_DIR)/2002.npy :
	$(DATA_EXE) --start "2002-01-01" --end "2002-12-31" --output-dir $(DATA_DIR)

$(DATA_DIR)/2003.npy :
	$(DATA_EXE) --start "2003-01-01" --end "2003-12-31" --output-dir $(DATA_DIR)

$(DATA_DIR)/2004.npy :
	$(DATA_EXE) --start "2004-01-01" --end "2004-12-31" --output-dir $(DATA_DIR)

# fit models
$(MODEL_DIR)/2001.pkl : $(DATA_DIR)/2000.npy
	$(TRAIN_EXE) --year 2001 --data-dir $(DATA_DIR) --output-dir $(MODEL_DIR)

$(MODEL_DIR)/2002.pkl : $(DATA_DIR)/2001.npy $(DATA_DIR)/2000.npy
	$(TRAIN_EXE) --year 2002 --data-dir $(DATA_DIR) --output-dir $(MODEL_DIR)

$(MODEL_DIR)/2003.pkl : $(DATA_DIR)/2002.npy $(DATA_DIR)/2001.npy $(DATA_DIR)/2000.npy
	$(TRAIN_EXE) --year 2003 --data-dir $(DATA_DIR) --output-dir $(MODEL_DIR)

$(MODEL_DIR)/2004.pkl : $(DATA_DIR)/2003.npy $(DATA_DIR)/2002.npy $(DATA_DIR)/2001.npy $(DATA_DIR)/2000.npy
	$(TRAIN_EXE) --year 2004 --data-dir $(DATA_DIR) --output-dir $(MODEL_DIR)

# forecast models
$(FORECAST_DIR)/2001.npy : $(MODEL_DIR)/2001.pkl $(DATA_DIR)/2001.npy
	$(FORECAST_EXE) --year 2001 --data-dir $(DATA_DIR) --model-dir $(MODEL_DIR) --output-dir $(FORECAST_DIR)

$(FORECAST_DIR)/2002.npy : $(MODEL_DIR)/2002.pkl $(DATA_DIR)/2002.npy
	$(FORECAST_EXE) --year 2002 --data-dir $(DATA_DIR) --model-dir $(MODEL_DIR) --output-dir $(FORECAST_DIR)

$(FORECAST_DIR)/2003.npy : $(MODEL_DIR)/2003.pkl $(DATA_DIR)/2003.npy
	$(FORECAST_EXE) --year 2003 --data-dir $(DATA_DIR) --model-dir $(MODEL_DIR) --output-dir $(FORECAST_DIR)

$(FORECAST_DIR)/2004.npy : $(MODEL_DIR)/2004.pkl $(DATA_DIR)/2004.npy 
	$(FORECAST_EXE) --year 2004 --data-dir $(DATA_DIR) --model-dir $(MODEL_DIR) --output-dir $(FORECAST_DIR)
```

## V4
Introduce make special characters to make it DRY

## V5 
