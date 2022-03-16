PYTHON=python
DATA_DIR=fake_data
FORECAST_DIR=forecasts
MODEL_DIR=models

DATA_EXE=$(PYTHON) data.py
FORECAST_EXE=$(PYTHON) forecast.py
TRAIN_EXE=$(PYTHON) modeling.py

START=2000
END=2004

DATA_YEARS := $(shell seq $(START) $(END))
DATA_FILES := $(patsubst %, $(DATA_DIR)/%.npy, $(DATA_YEARS))

MODEL_FILES := $(patsubst $(DATA_DIR)/%.npy, $(MODEL_DIR)/%.pkl, $(DATA_FILES))
MODEL_FILES := $(filter-out $(MODEL_DIR)/$(START).npy, $(MODEL_FILES))

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
	@echo MODEL_FILES: $(MODEL_FILES)
	@echo FORECAST_FILES: $(FORECAST_FILES)

# pull data
$(DATA_FILES) : $(DATA_DIR)/%.npy :
	$(DATA_EXE) --start "$*-01-01" --end "$*-12-31" --output-dir $(DATA_DIR)

# fit models
.SECONDEXPANSION:
$(MODEL_DIR)/%.pkl : $$(filter-out $$*.npy,$$(foreach num,$$(shell seq $(START) %),$(DATA_DIR)/$$(num).npy))
	$(TRAIN_EXE) --year $* --data-dir $(DATA_DIR) --output-dir $(MODEL_DIR)

# forecast models
$(FORECAST_FILES) : $(FORECAST_DIR)/%.npy : $(MODEL_DIR)/%.pkl $(DATA_DIR)/%.npy
	$(FORECAST_EXE) --year $* --data-dir $(DATA_DIR) --model-dir $(MODEL_DIR) --output-dir $(FORECAST_DIR)

# graph DAG
makefile-dag.png: MakefileV7.mk
	make -Bnd -f $< | make2graph | dot -Tpng -Gdpi=300 -o $@