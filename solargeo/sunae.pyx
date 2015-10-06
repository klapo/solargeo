'''Solar Geometry Function'''

from __future__ import division
import numpy as np
import pandas as pd

# Constants
rpd = np.pi / 180.
twopi = np.pi * 2

def sunae(timestamp, lat, lon, refraction_flag=True):
    '''
    Calculates the local solar azimuth and elevation angles, and
    the distance to and angle subtended by the Sun, at a specifi#
    location and time using approximate formulas in The Astronomical
    Almanac.  Accuracy of angles is 0.01 deg or better (the angular
    width of the Sun is about 0.5 deg, so 0.01 deg is more than
    sufficient for most applications).

    Unlike many GCM (and other) sun angle routines, this
    one gives slightly different sun angles depending on
    the year.  The difference is usually down in the 4th
    significant digit but can slowly creep up to the 3rd
    significant digit after several decades to a century.

    A refraction correction appropriate for the "US Standard
    Atmosphere" is added, so that the returned sun position is
    the APPARENT one.  The correction is below 0.1 deg for solar
    elevations above 9 deg.  This refraction correction is assumed on,
    but can be toggled using the "refraction_flag" keyword.

    Only accurate between 1950 and 2050.

    Parameters
    ----------
    timestamp : datetime like object or objects
        Timestamp at which to calculate local solar azimuth and elevation angles
    lat : float
       latitude in degrees - north is positive
    lon : float
       longitude in degrees - east is positive

    Possible arrays:
        - 1 time step w/ 2D space (arrays in lat and lon)
        - arrays in lat, lon, and time (recommended: use meshgrid output of
            input variables)

    Returns
    -------
    az : solar azimuth angle (measured east from north, 0 to 360 degs)
    el :  solar elevation angle (angle above the horizon)
    soldst : distance to sun [Astronomical Units, AU]
              (1 AU = mean Earth-sun distance = 1.49597871E+11 m)

    References
    ----------
    [1] Michalsky, J., 1988: The Astronomical Almanac's algorithm for
    approximate solar position (1950-2050), Solar Energy 40,
    227-235 (but the version of this program in the Appendix
    contains errors and should not be used)
    [2] The Astronomical Almanac, U.S. Gov't Printing Office, Washington,
    D.C. (published every year): the formulas used from the 1995
    version are as follows:
       p. A12: approximation to sunrise/set times
       p. B61: solar elevation ("altitude") and azimuth
       p. B62: refraction correction
       p. C24: mean longitude, mean anomaly, eclipti#longitude,
               obliquity of ecliptic, right ascension, declination,
               Earth-Sun distance, angular diameter of Sun
       p. L2:  Greenwich mean sidereal time (ignoring T^2, T^3 terms)

    History
    -------
    (fortran) Authors:  Dr. Joe Michalsky (joe@asrc.albany.edu)
            Dr. Lee Harrison (lee@asrc.albany.edu)
            Atmospheri#Sciences Research Center
            State University of New York
            Albany, New York
    (fortran) Modified by:  Dr. Warren Wiscombe (wiscombe@climate.gsfc.nasa.gov)
                NASA Goddard Space Flight Center
                Code 913
                Greenbelt, MD 20771
    (python)  Converted to python: Karl Lapo (lapo.karl@gmail.com)

    See Also
    --------
    avg_el: average elevation angle
     '''
    #  Local Variables:
    #    dec       Declination (radians)
    #    eclon    Eclipti#longitude (radians)
    #    gmst      Greenwich mean sidereal time (hours)
    #    ha        Hour angle (radians, -pi to pi)
    #    jd        Modified Julian date (number of days, including
    #              fractions thereof, from Julian year J2000.);
    #              actual Julian date is jd + 2451545.
    #    lmst      Local mean sidereal time (radians)
    #    mnanom    Mean anomaly (radians, normalized to 0 to 2*pi)
    #    mnlon    Mean longitude of Sun, corrected for aberration
    #              (deg; normalized to 0-360)
    #    oblqec    Obliquity of the eclipti#(radians)
    #    ra        Right ascension  (radians)
    #    refrac    Refraction correction for US Standard Atmosphere (degs)

    # Coerce inputs to desired types
    lat = np.atleast_1d(lat)
    lon = np.atleast_1d(lon)
    if not isinstance(timestamp, pd.DatetimeIndex):
        # try to convert to a DatetimeIndex
        timestamp = pd.DatetimeIndex(np.atleast_1d(timestamp))

    # Error handling
    if np.min(timestamp.year) < 1950 or np.max(timestamp.year) > 2050:
        raise ValueError('year must be between 1950 and 2050')
    if np.min(lat) < -90. or np.max(lat) > 90.:
        raise ValueError('lat must be between -90 and 90')
    if np.min(lon) < -180. or np.max(lon) > 180.:
        raise ValueError('lon must be between -180 and 180')

    # Check array dimensions - need to add check for type (has to be ndarray,
    # not float. Indexing breaks otherwise)
    if lat.shape != lon.shape:
        raise ValueError('Latitude and Longitude must be arrays of same size '
                         '-- use numpy.meshgrid')
    if timestamp.size > 1 and lat.size > 1:
        if lat.shape != timestamp.shape:
            raise ValueError('Broadcasting arrays in both time and space '
                             'requires output from numpy.meshgrid -- all '
                             'arrays must be the same size')

    # Julian date/Coordinates
    # Add 2,400,000 for true jd
    # 32916.5 is midnite 0 jan 1949 minus 2.4e6
    jd = timestamp.to_julian_date().values - 2400000.

    # ecliptic coordinates: 51545. + 2.4e6 = noon 1 jan 2000
    time = jd - 51545.

    # force mean longitude between 0 and 360 degs
    mnlon = 280.460 + 0.9856474 * time
    mnlon = np.mod(mnlon, 360.)
    inds = np.nonzero(mnlon < 0.)
    mnlon[inds] += 360.

    # mean anomaly in radians between 0 and 2*pi
    mnanom = 357.528 + 0.9856003 * time
    mnanom = np.mod(mnanom, 360.)
    inds = np.nonzero(mnanom < 0.)
    mnanom[inds] += 360.
    mnanom = mnanom * rpd

    # ecliptic longitude and obliquity of ecliptic in radians
    eclon = mnlon + 1.915 * np.sin(mnanom) + 0.020 * np.sin(2. * mnanom)
    eclon = np.mod(eclon, 360.)
    inds = np.nonzero(eclon < 0.)
    eclon[inds] += 360
    eclon *= rpd
    oblqec = (23.439 - 0.0000004 * time) * rpd

    # el, az
    # right ascension
    num = np.cos(oblqec) * np.sin(eclon)
    den = np.cos(eclon)
    ra = np.arctan(num / den)

    # Force right ascension between 0 and 2*pi
    inds = np.nonzero(den < 0.)
    ra[inds] += np.pi
    inds = np.nonzero((num < 0.) & (den >= 0.))
    ra[inds] += twopi

    # declination
    dec = np.arcsin(np.sin(oblqec) * np.sin(eclon))

    # Greenwich mean sidereal time in hours
    gmst = 6.697375 + 0.0657098242 * time + _hours_since_midnight(timestamp)

    # Hour not changed to sidereal time since
    # 'time' includes the fractional day
    gmst = np.mod(gmst, 24.)
    inds = np.nonzero(gmst < 0.)
    gmst[inds] += 24

    # local mean sidereal time in radians
    lmst = gmst + lon / 15.
    lmst = np.mod(lmst, 24.)
    inds = np.nonzero(lmst < 0.)
    lmst[inds] += 24.
    lmst = lmst * 15. * rpd

    # hour angle in radians between -pi and pi
    ha = lmst - ra
    inds = np.nonzero(ha < -np.pi)
    ha[inds] += twopi
    inds = np.nonzero(ha > np.pi)
    ha[inds] -= twopi

    # solar azimuth and elevation
    el = np.arcsin(np.sin(dec) * np.sin(lat * rpd) +
                   np.cos(dec) * np.cos(lat * rpd) * np.cos(ha))
    az = np.arcsin(-np.cos(dec) * np.sin(ha) / np.cos(el))

    # Put azimuth between 0 and 2*pi radians
    inds = np.nonzero((np.sin(dec) - np.sin(el) * np.sin(lat * rpd) >= 0.) &
                      (np.sin(az) < 0.))
    az[inds] += twopi
    inds = np.nonzero(np.sin(dec) - np.sin(el) * np.sin(lat * rpd) < 0.)
    az[inds] = np.pi - az[inds]

    # Convert elevation and azimuth to degrees
    el /= rpd
    az /= rpd

    # Refraction correction for U.S. Standard Atmos.
    # (assumes elevation in degs) (3.51823=1013.25 mb/288 K)
    if refraction_flag:
        refrac = np.zeros_like(el)

        inds = np.nonzero(el >= 19.225)
        refrac[inds] = 0.00452 * 3.51823 / np.tan(el[inds] * rpd)
        inds = np.nonzero((el > -0.766) & (el < 19.225))
        refrac[inds] =\
            3.51823 * (0.1594 + el[inds] * (0.0196 + 0.00002 * el[inds])) /\
            (1. + el[inds] * (0.505 + 0.0845 * el[inds]))
        inds = np.nonzero(el <= -0.766)
        refrac[inds] = 0.

        el += refrac

    # soldst, distance to sun in A.U.
    soldst = 1.00014 - 0.01671 * np.cos(mnanom) - 0.00014 * np.cos(2. * mnanom)

    # Complete
    if np.min(el) < -90. or np.max(el) > 90.:
        raise ValueError('Calculated el out of range')
    if np.min(az) < 0. or np.max(az) > 360.:
        raise ValueError('Calculated az out of range')
    inds = np.nonzero(el < 0)
    el[inds] = 0

    return el, az, soldst


def _hours_since_midnight(t):
    '''Calculate the time since midnight in hours'''
    return (t.hour + t.minute / 60. + t.second / 3600. +
            t.microsecond / (1e-6 * 3600.))
