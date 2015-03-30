# solargeo
Scripts and functions for calculating solar geometry variables for a given time and location.

Two functions are included in the script:

1) SUNAE - python/cython conversion of fortran code originally developed by Dr. Warren Wiscombe and Dr. Joe Michalsky (ftp://climate1.gsfc.nasa.gov/wiscombe/Solar_Rad/SunAngles/sunae.f). Calculates solar zenith angle/elevation angle, solar azimuth angle, and normalized solar distance for a given time and location.

2) AVG_EL - Finds the average of the cosine(solar zenith angle) for an interval. This is necessary when handling solar irradiances averaged over some interval (e.g., hourly observations) as the solar zenith angle has a convex shape. Linear averaging or assuming an instantaneous value for the solar zenith angle will lead to errors, especially for longer averaging periods. Averages by integrating the cos(SZA) at five minute intervals. 

An example of why this is important can be found here: http://onlinelibrary.wiley.com/doi/10.1002/2015GL063239/full 

Code is sort of set up for using cython... 
