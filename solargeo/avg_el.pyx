'''Average Elevation Angle'''

from __future__ import division
import numpy as np
import pandas as pd
from pandas.tseries.frequencies import to_offset
from solargeo import sunae

rpd = np.pi / 180.

def avg_el(time, lat, lon, ref='BEG', integral_freq='5Min'):
    '''
    Calculates the average cosine solar zenith angle during the time interval
    and returns the effective elevation angle. For instantaneous elevation
    values call solargeo.sunae directly.

    Converts timestamp/labels to beginning of bin.

    Parameters
    ----------
    time : datetime index
        assumed to be in UTC, conversion should occur outside of function
    lat : float
        site latitude (north is positive)
    lon : float
        site longitude (east is positive)
    ref : str, {'BEG', 'MID', 'END'}
        Argument describing how the data is referenced to the time stamp. The
        default assumption is that the time stamp is for the beginning of the
        averaging interval. This argument must be specified for accuracy if the
        default value is not true.  Options:
            'END' - averaged data referenced to the interval end
            'MID' - averaged data referenced to the interval middle
            'BEG' - averaged data referenced to the interval beginning
    integral_freq : str
        Pandas frequency defining the size of the sub-timestep integral unit.

    Returns
    -------
    el = pandas.Series
        Average elevation angle (degrees above horizon)

    Notes
    -----
    THIS CODE DOES NOT HANDLE DISCONTINUOUS DATA (YET)

    See Also
    --------
    sunae: solar geometry function

    '''

    dts = list(set(np.diff(time.values)))
    if len(dts) > 1:
        raise NotImplementedError('Can not handle discontinuous data yet.')
    else:
        dt = pd.Timedelta(dts[0])  # Time step (timedelta object)

    # Time stamp referenced moved to the beginning of the averaging period
    if ref.upper() == 'BEG':
        pass  # do nothing
    elif ref.upper() == 'MID':
        time -= dt / 2.
    elif ref.upper() == 'END':
        time -= dt
    else:
        raise ValueError('Unrecognized ref option {0}'.format(ref))

    # Instantaneous elevation angle -> 5 minute time step integration
    # Discretize current time step
    t_fine_beg = time[0]
    t_fine_end = time[-1]
    t_fine = pd.date_range(start=t_fine_beg, end=t_fine_end,
                           freq=integral_freq).tz_localize('UTC')

    # Numerical integration of fine el
    el_fine, _, _ = sunae(t_fine, lat, lon, refraction_flag=True)
    mew_fine = pd.Series(data=np.sin(el_fine * rpd), index=t_fine)
    el_fine = np.arcsin(mew_fine) / rpd

    # Average elevation angle at original timestep
    mew_coarse = mew_fine.resample(rule=to_offset(dt).freqstr,
                                   how='mean', label='left')
    mew_coarse.tz_localize(time.tz)
    el = np.arcsin(mew_coarse) / rpd
    el = el.clip(lower=0, upper=None)

    return el
