function [EL, AZ, SOLDIST, HA, DEC] = SolarGeometry_v2(t,lat,long,zone,REF,varargin)
% Gives the elevation angle, azimuth, normalized Earth-Sun distance, and solar
% hour angle for a specified locaiton. Calls sunang.m, which is based on
% Whiscombe's algorithm.
%
%	NOTE: THIS ALGORITHM GIVES INSTANTANEOUS VALUES
%
% SYNTAX:
% 	[EL, AZ, SOLDIST, HA] = SolarGeometry(t,lat,long,zone)
%	[EL, AZ, SOLDIST, HA] = SolarGeometry(t,lat,long,zone,REF)
%
% INPUTS:
%	t		= Lx7 time_builder matrix
%	lat		= 1x1 value of latitude (+ N, - S)
%	long	= 1x1 value of longitude (+E,-W)
%	zone	= 1x1 value of time zone from GMT
%	REF		= char string - indicating how the data is referenced to the time
%		'BEG': Data in time step referenced to the beginning of the averaging period
%		'END': Data in time step referenced to the end of the averaging period
%
% OUTPUTS
%	EL		= Lx1 vector of elevation angle (angle above horizon)
%	AZ		= Lx1 vector of azimuth angle
%	SOLDIST	= Lx1 vector of normalized Earth-Sun distance
%	HA		= Lx1 vector of hour angle (for sunrise, sunset, and solar noon)
% 
% DEPENDENCIES:
%	sunang.m
%	Get_dt.m

% Pre-allocate
len = size(t,1);
EL = NaN(len,1);
AZ = NaN(len,1);
SOLDIST = NaN(len,1);
HA = NaN(len,1);
DEC = NaN(len,1);

if nargin == 5
	dt = Get_dt(t);							% Find the time step in minutes (serial format)
	if strcmp(REF,'BEG')					% Obs. avg. referenced to beginning of time step
		t = time_builder(t(:,7) + dt./2);	% Move time window to be in the middle of averaging period	
	elseif strcmp(REF,'END')				% Obs. avg. referenced to the end of time step
		t = time_builder(t(:,7) - dt./2);	% Move time window to be in the middle of averaging period
	elseif strcmp(REF,'MID')				% Already referenced to the middle of the interval
		t = t;								% Do nothing
	else
		error('Unrecognized REF option')
	end
end

% Find the elevation, azimuth, and normalized solar distance.
for n = 1:len
	% Find integer Julian day
	JD = floor(t(n,6));
	% Find decimal hour
	HHMM = t(n,4) + t(n,5)./60;
	% Call sunang
	[EL(n),AZ(n),SOLDIST(n),DEC(n),HA(n)] = sunang(t(n,1),JD,HHMM+zone,lat,long);
end

% Force night time
EL(EL < 0) = 0;
