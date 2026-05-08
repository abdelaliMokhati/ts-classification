# TSAC GROUP PROJECT

# SETUP
```bash
pip install -r requirement.txt
```

# DATA

The data provided in the challenge follows the .csv format. You can find it
under data/raw.

In addition, you find the data in .ts format, which is compatible with sktime
library. "sktime" is the main

used library for this study.

# Notebooks

## Main notebook for sumbission

`notebooks/main.ipynb`

## Notebook for further study

Please create a new notebook in `notebooks/<your-name>` To avoid merge conflicts
&nbsp; &nbsp; &nbsp; (e.g. notebooks/abdelali)

**NOTE**

1. To avoid merge conflicts, please ensure to use this variable for your outputs

```py
OUTPUT_PATH = os.path.join(".","submission", "output", "y_pred.csv")
```

2. `output` directory is git-ignored
