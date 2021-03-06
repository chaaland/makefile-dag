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

.PHONY : all clean variables

all: $(FORECAST_DIR)/2001.npy $(FORECAST_DIR)/2002.npy $(FORECAST_DIR)/2003.npy $(FORECAST_DIR)/2004.npy

clean : 
	rm -rf $(MODEL_DIR)/ $(FORECAST_DIR)/ $(DATA_DIR)/

# print defined variables
variables :
	@echo DATA_EXE: $(DATA_EXE)
	@echo TRAIN_EXE: $(TRAIN_EXE)
	@echo FORECAST_EXE: $(FORECAST_EXE)
	@echo DATA_FILES: $(DATA_FILES)

# pull data
$(DATA_FILES) : $(DATA_DIR)/%.npy :
	$(DATA_EXE) --start "$*-01-01" --end "$*-12-31" --output-dir $(DATA_DIR)

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

# graph DAG
makefile-dag.png: MakefileV5.mk
	make -Bnd -f $< | make2graph | dot -Tpng -Gdpi=300 -o $@