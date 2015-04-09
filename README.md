# solargeo
Scripts and functions for calculating solar geometry variables for a given time and location.

Two functions are included in the script:

1) SUNAE - python/cython conversion of fortran code originally developed by Dr. Warren Wiscombe and Dr. Joe Michalsky (ftp://climate1.gsfc.nasa.gov/wiscombe/Solar_Rad/SunAngles/sunae.f). Calculates solar zenith angle/elevation angle, solar azimuth angle, and normalized solar distance for a given time and location.

2) AVG_EL - Finds the average of the cosine(solar zenith angle) for an interval. This is necessary when handling solar irradiances averaged over some interval (e.g., hourly observations) as the solar zenith angle has a convex shape. Linear averaging or assuming an instantaneous value for the solar zenith angle will lead to errors, especially for longer averaging periods. Averages by integrating the cos(SZA) at five minute intervals. 

An example of why using the correct average SZA is important can be found here: http://onlinelibrary.wiley.com/doi/10.1002/2015GL063239/full 

##################
Examples of SUNAE usage. Only some combinations of space and time arrays are allowed.

lat = vector, length 32
lon = vector, length 44
NLDAS_datetime_H = datetime ndarray, length 4648 

# Testing 'SUNAE' with broadcasting (instantaneous elevation angle values)
import numpy as np
lat_size = np.shape(lat)
lon_size = np.shape(lon)
lat_m, lon_m = np.meshgrid(lat,lon)
t_size = np.shape(NLDAS_datetime_H)

### Loop over times in 2D spacial array
EL = np.zeros((lon_size[0],lat_size[0],t_size[0]))

for ind,time_step in enumerate(NLDAS_datetime_H):
    yyyy = np.array([time_step.year])
    jday = np.array([time_step.timetuple().tm_yday])
    hh = np.array([time_step.hour+time_step.minute/60.])

    EL[:,:,ind] = SUNAE(yyyy,jday,hh,lat_m,lon_m)[0]
(EL shape = 32, 44, 4648)

### Broadcast to 3D array
EL = np.zeros((lon_size[0],lat_size[0],t_size[0]))
yyyy = np.zeros(t_size[0])
jday = np.zeros(t_size[0])
hh = np.zeros(t_size[0])

for ind,time_step in enumerate(NLDAS_datetime_H):
    yyyy[ind] = np.array([time_step.year])
    jday[ind] = np.array([time_step.timetuple().tm_yday])
    hh[ind] = np.array([time_step.hour+time_step.minute/60.])

# mesh lat, lon, and time variables
lat_m,lon_m,yyyy_m = np.meshgrid(lat,lon,yyyy)
jday_m = np.meshgrid(lat,lon,jday)[2]
hh_m = np.meshgrid(lat,lon,hh)[2]

EL = SUNAE(yyyy_m,jday_m,hh_m,lat_m,lon_m)[0]
(EL shape = 32,44,4648)
