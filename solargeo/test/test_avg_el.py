import pandas as pd
from engarde import checks

from solargeo import avg_el


def test_avg_el():
    time = pd.date_range(start='1951-01-01', end='2049-12-31', freq='3H')
    lat, lon = 47.6097, 122.3331  # seattle
    el = avg_el(time, lat, lon, ref='BEG')

    assert isinstance(el, pd.Series)
    df = pd.DataFrame({'el': el})
    checks.none_missing(df)
    checks.unique_index(df)
    checks.within_range(df, items={'el': (0, 90)})
