function EL = AVG_EL(TIME,lat,lon,tz,REF)
% Calculates the average cosSZA during the time interval and returns the
% effective elevation angle.
%
% SYNTAX:
%	EL = AVG_EL(TIME,lat,lon,tz,REF)
%
% INPUTS:
%	TIME	= Nx7 matrix - time_builder format time
%	lat		= 1x1 scalar - degrees north
%	lon		= 1x1 scalar - degrees west
%	tz		= 1x1 sclar - # of time zones West of UTC
%	REF		= string - argument describing how the data is referenced to the time stamp
%			The default assumption is that the time stamp is for the beginning of the 
%			averaging interval. This argument must be specified for accuracy if the
%			default value is not true.
%			'END' - averaged data referenced to the end of the interval
%			'MID' - averaged data referenced to the middle of the interval
%			'BEG' - averaged data referenced to the beginning of the
%			interval
%
% OUTPUTS:
%	EL		= Nx1 vector - Average elevation angle [degrees above horizon]
%
% DEPENDENCIES:
%	SolarGeometry.m
%	Get_dt.m
%	TimeIndex.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHECKS/INITIAL FORMATTING %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(TIME,2) ~=7 && size(TIME,2) ~= 1
	error('TIME variable must either be a time_builder format matrix or a vector of serial dates')
end
if size(TIME,2) == 7
	TIME = TIME(:,7);							% Use just the serial dates
end

% Referencing needs to be adjusted to the beginning of the averaging period
dt = Get_dt(TIME);								% Find the time step (serial format)
if strcmp(REF,'END')							% Obs. avg. referenced to end of time step
	TIME = TIME - dt;							% Time should be referenced to the beginning of the averaging period	
elseif strcmp(REF,'MID')						% Obs. avg. referenced to the middle of time step
	TIME = TIME - dt./2;						% Time should be referenced to the beginning of the averaging period			
elseif ~strcmp(REF,'BEG') && ~strcmp(REF,'MID') && ~strcmp(REF,'END')
	error('Unrecognized REF option')
end

% Instantaneous elevation angle
dt_f = 1/12;									% 5 minute time step in integration
t_fine = time_builder(TIME(1),TIME(end)+dt,dt_f);% Time interval diced fine time step
EL_fine = SolarGeometry_v2(t_fine,lat,lon,tz);	% Solar geometry for fine time step
mew_fine = sind(EL_fine);	

% Average elevation angle
TIND = TimeIndex(t_fine,dt);					% Indices of one time step
cosSZA = NaN(size(TIND,1),1);					% Pre-allocate w/ NaNs
for n = 1:size(TIND,1)
	IND = TIND(n,1):TIND(n,2);					% Interval index
	mew_int = mew_fine(IND);
	cosSZA(n,1) = mean(mew_int(mew_int > 0));	% mean(cos(SZA)) over period
	if isnan(cosSZA(n,1))
		cosSZA(n,1) = 0;
	end
end

% Convert from avg(cos(SZA)) to elevation angle
EL = asind(cosSZA);