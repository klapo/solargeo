###################################################################
################## Average Elevation Angle ########################
###################################################################

def AVG_EL(TIME,lat,lon,tz,REF):
# Calculates the average cosSZA during the time interval and returns the
# effective elevation angle. For instantaneous EL values call SUNAE directly.
# Converts timestamp/labels to beginning of bin.
#
# THIS CODE DOES NOT HANDLE DISCONTINUOUS DATA (YET)
#
# SYNTAX:
#   EL = AVG_EL(TIME,lat,lon,tz,REF)
#
# INPUTS:
#   TIME    = Nx1 datetime object (assumed to be in UTC, conversion should occur outside of function)
#   lat     = 1x1 scalar, site latitude (north = pos)
#   lon     = 1x1 scalar, site longitude (east = pos)
#   tz      = 1x1 scalar, # of timezones west of UTC (if date not in UTC)
#   REF     = string - argument describing how the data is referenced to the time stamp
#           The default assumption is that the time stamp is for the beginning of the 
#           averaging interval. This argument must be specified for accuracy if the
#           default value is not true.
#           'END' - averaged data referenced to the interval end
#           'MID' - averaged data referenced to the interval middle
#           'BEG' - averaged data referenced to the interval beginning
#
# OUTPUTS:
#   EL      = Nx1 vector - Average elevation angle [degrees above horizon]
#
# DEPENDENCIES:
#   SUNAE

    ## Libraries
    import solargeometry
    import numpy as np
    from datetime import datetime, timedelta
    import pandas as pd

    # Time stamp referenced moved to the beginning of the averaging period
    dt = TIME[1]-TIME[0] # Time step (timedelta object)
    if REF=='END':
        TIME = TIME[:] - dt
    elif REF=='MID':
        TIME = TIME[:] - dt/2
    elif REF!='BEG' & REF!='MID' & REF!='END':
        raise ValueError('Unrecognized REF option')

    # Instantaneous elevation angle -> 5 minute time step integration
    # Discretize current time step
    t_fine_beg = TIME[0]
    t_fine_end = TIME[-1]
    t_fine = pd.date_range(start=t_fine_beg,end=t_fine_end,freq='5Min')

    # Numerical integration of fine EL
    yyyy = t_fine.year
    jday = t_fine.dayofyear
    hh = t_fine.hour+t_fine.minute/60.+tz
    EL_fine = solargeometry.SUNAE(yyyy,jday,hh,lat,lon)[0]
    mew_fine = pd.DataFrame(data=np.sin(EL_fine*np.pi/180.), index=t_fine, columns=['el_ang'])
    EL_fine = np.arcsin(mew_fine['el_ang'])*180./np.pi

    # Average elevation angle at original timestep
    resample_rule_secs = str(dt.seconds)+'S'
    mew_coarse = mew_fine.resample(resample_rule_secs,how='mean',label='left')
    EL = np.arcsin(mew_coarse['el_ang'])*180./np.pi
    EL = EL.where(EL>0,0)
    return(EL)

