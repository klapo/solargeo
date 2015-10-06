import pandas as pd
from engarde import checks

from solargeo import sunae


def test_sunae():
    lat, lon = 47.6097, 122.3331  # seattle
    time = pd.Timestamp('2015-09-27')

    el, az, soldst = sunae(time, lat, lon, refraction_flag=True)

    df = pd.DataFrame({'el': el})
    checks.none_missing(df)
    checks.unique_index(df)
    checks.within_range(df, items={'el': (0, 90)})
