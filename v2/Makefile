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
