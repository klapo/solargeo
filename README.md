# solargeo
Scripts and functions for calculating solar geometry variables for a given time and location.

Two functions are included in the script:

1) SUNAE - python/cython conversion of [fortran code](ftp://climate1.gsfc.nasa.gov/wiscombe/Solar_Rad/SunAngles/sunae.f) originally developed by Dr. Warren Wiscombe and Dr. Joe Michalsky. Calculates solar zenith angle/elevation angle, solar azimuth angle, and normalized solar distance for a given time and location.

2) AVG_EL - Finds the average of the cosine(solar zenith angle) for an interval. This is necessary when handling solar irradiances averaged over some interval (e.g., hourly observations) as the solar zenith angle has a convex shape. Linear averaging or assuming an instantaneous value for the solar zenith angle will lead to errors, especially for longer averaging periods. Averages by integrating the cos(SZA) at five minute intervals.

An example of why using the correct average SZA is important can be found here: http://onlinelibrary.wiley.com/doi/10.1002/2015GL063239/full

### Requirements

- [Python](https://www.python.org/) version 2.7+ or 3.4+
- [Cython](http://cython.org/) version 0.23+
- [pandas](http://pandas.pydata.org/pandas-docs/stable/index.html) version 0.16+
- [numpy](http://www.numpy.org/) version 1.9+

### Installing
From the command line, type:

```python setup.py install```
