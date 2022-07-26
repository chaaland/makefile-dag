PYTHON=python
DATA_DIR=fake_data
FORECAST_DIR=forecasts
MODEL_DIR=models

DATA_EXE=$(PYTHON) data.py
FORECAST_EXE=$(PYTHON) forecast.py
TRAIN_EXE=$(PYTHON) modeling.py

START=2000
END=2003

DATA_YEARS := $(shell seq $(START) $(END))
PREDICTOR_FILES := $(patsubst %, $(DATA_DIR)/p_%.npy, $(DATA_YEARS))
RESPONSE_FILES := $(patsubst %, $(DATA_DIR)/r_%.npy, $(DATA_YEARS))

FORECAST_FILES := $(patsubst $(DATA_DIR)/p_%, $(FORECAST_DIR)/f_%, $(PREDICTOR_FILES))
FORECAST_FILES := $(filter-out $(FORECAST_DIR)/f_$(START).npy, $(FORECAST_FILES))

MODEL_FILES := $(patsubst $(FORECAST_DIR)/f_%.npy, $(MODEL_DIR)/m_%.pkl, $(FORECAST_FILES))

.PHONY : all clean variables

all: $(FORECAST_FILES)

clean : 
	rm -rf $(MODEL_DIR)/ $(FORECAST_DIR)/ $(DATA_DIR)/

# print defined variables
variables :
	@echo DATA_EXE: $(DATA_EXE)
	@echo TRAIN_EXE: $(TRAIN_EXE)
	@echo FORECAST_EXE: $(FORECAST_EXE)
	@echo PREDICTOR_FILES: $(PREDICTOR_FILES)
	@echo RESPONSE_FILES: $(RESPONSE_FILES)
	@echo MODEL_FILES: $(MODEL_FILES)
	@echo FORECAST_FILES: $(FORECAST_FILES)

data: $(RESPONSE_FILES) $(PREDICTOR_FILES)

models: $(MODEL_FILES)

forecasts: $(FORECAST_FILES)

$(PREDICTOR_FILES) : $(DATA_DIR)/%.npy :
	@touch $(DATA_DIR)/$*.npy

$(RESPONSE_FILES) : $(DATA_DIR)/%.npy :
	@touch $(DATA_DIR)/$*.npy


# fit models
.SECONDEXPANSION:
$(MODEL_DIR)/m_%.pkl : $$(filter-out $(DATA_DIR)/p_$$*.npy,$$(foreach num,$$(shell seq $(START) %),$(DATA_DIR)/p_$$(num).npy)) $$(filter-out $(DATA_DIR)/r_$$*.npy,$$(foreach num,$$(shell seq $(START) %),$(DATA_DIR)/r_$$(num).npy))
	@touch $@


# forecast models
$(FORECAST_FILES) : $(FORECAST_DIR)/f_%.npy : $(MODEL_DIR)/m_%.pkl $(DATA_DIR)/p_%.npy $(DATA_DIR)/r_%.npy
	@touch $(FORECAST_DIR)/$*.npy

# graph DAG
makefile-data-dag.png: MakefileTheseus.mk
	make -Bnd -f $< data | make2graph | dot -Tpng -Gdpi=300 -o $@

makefile-model-dag.png: MakefileTheseus.mk
	make -Bnd -f $< models | make2graph | dot -Tpng -Gdpi=300 -o $@

makefile-forecast-dag.png: MakefileTheseus.mk
	make -Bnd -f $< forecasts | make2graph | dot -Tpng -Gdpi=900 -o $@