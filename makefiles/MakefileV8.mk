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

DATA_YEARS := $(shell seq $(START) $(END))
DATA_FILES := $(patsubst %, $(DATA_DIR)/%.npy, $(DATA_YEARS))

FORECAST_FILES := $(patsubst $(DATA_DIR)/%, $(FORECAST_DIR)/%, $(DATA_FILES))
FORECAST_FILES := $(filter-out $(FORECAST_DIR)/$(START).npy, $(FORECAST_FILES))

.PHONY : all clean variables

all: $(FORECAST_FILES)

clean : 
	rm -rf $(MODEL_DIR)/ $(FORECAST_DIR)/ $(DATA_DIR)/

# print defined variables
variables :
	@echo DATA_EXE: $(DATA_EXE)
	@echo TRAIN_EXE: $(TRAIN_EXE)
	@echo FORECAST_EXE: $(FORECAST_EXE)
	@echo DATA_FILES: $(DATA_FILES)
	@echo FORECAST_FILES: $(FORECAST_FILES)

# pull data
$(DATA_FILES) : $(DATA_DIR)/%.npy : $(DATA_SRC)
	$(DATA_EXE) --start "$*-01-01" --end "$*-12-31" --output-dir $(DATA_DIR)

# fit models
.SECONDEXPANSION:
$(MODEL_DIR)/%.pkl : $$(filter-out $$*.npy,$$(foreach num,$$(shell seq $(START) %),$(DATA_DIR)/$$(num).npy)) $(TRAIN_SRC)
	$(TRAIN_EXE) --year $* --data-dir $(DATA_DIR) --output-dir $(MODEL_DIR)

# forecast models
$(FORECAST_FILES) : $(FORECAST_DIR)/%.npy : $(MODEL_DIR)/%.pkl $(DATA_DIR)/%.npy $(FORECAST_SRC)
	$(FORECAST_EXE) --year $* --data-dir $(DATA_DIR) --model-dir $(MODEL_DIR) --output-dir $(FORECAST_DIR)

# graph DAG
makefile-dag.png: MakefileV8.mk
	make -Bnd -f $< | make2graph | dot -Tpng -Gdpi=300 -o $@