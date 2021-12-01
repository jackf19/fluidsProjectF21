clear; clc; dfs;
%% Given
W = 20000 * 907.185;      % displacement: ton -> kg
T_sea = 15 + 273;       % water temperature: C -> K
rho_sea = 1025;         % water density: kg/m^3
mu_sea = 0.00122;       % water viscosity: Ns/m^2
rho_air = 1.225;        % air density: kg/m^3
mu_air = 1.7894e-5;     % air viscosity: Ns/m^2
p_atm = 101325;         % atmospheric pressure: Pa
A = 20000;              % hull wetted area: m^2
SFC = 168;              % specific fuel consumption: g/kWh
Fi = 2.75;              % CO2 intensity of fuel: gCO2/gfuel
L = 200;                % ship length: m
Cw = 3*10^-4;           % wave-making resistance coefficient
Vc = 19 / 1.94384;        % cruise velocity: kt -> m/s
Va = 60 / 1.94384;        % apparent wind speed: kt -> m/s
np = 0.5;               % propulsive efficiency
h = 0.00125;            % righting lever arm: m
eff = 0.9;              % span efficiency factor
sigmaYield = 100*10^6;     % yield strength: Pa
g = 9.81;               % m/s^2

%% Variable Parameters
b = 10:2:40;
c = 2:2:10;
cam = 1:4;
camLoc = 2:4;
tmax = 3:12; % must be <= 12
AoA = 0:2:12;

%% Preliminary Calculations
Cf = 0.0004; % CHANGE THIS
qinf = 0.5 * rho_air * Va^2;
FR = (Cf + Cw) * 0.5 * rho_air * Va^2 * A; % water resistance
RT = h * W * g; % righting torque

Re = (rho_air * Va * c)/mu_air; % vector of Re for each chord length
Mach = Va/sqrt(T_sea*1.4*287); % do we need temperature of air for this?

%% Set up table to store XFOIL data
vecSize = length(b) * length(c) * length(cam) * length(camLoc) * length(tmax) * length(AoA);

span = NaN(vecSize, 1);
chord = NaN(vecSize, 1);
foils = strings(vecSize, 1);
Cl = NaN(vecSize, 1);
Cd = NaN(vecSize, 1);
thickness = NaN(vecSize, 1);
alpha = NaN(vecSize, 1);
stress = NaN(vecSize, 1);
stability = NaN(vecSize, 1);
viable = false(vecSize, 1);
emission = NaN(vecSize, 1);

data = table(viable, emission, foils, thickness, span, chord, alpha, Cl, Cd, stress, stability);

%% Loop through all parameters
absIndex = 1;
for i=1:length(b)  % for each span...
    for j=1:length(c)  % for each chord...
        for k=1:length(cam)  % for each max camber...
            for l=1:length(camLoc)  % for each max camber location...
                for m=1:length(tmax) % for each thickness...
                    
                    % generate NACA string using camber and thickness i.e. "NACA2412"
                    nacaFoil = "naca" + num2str(1000*cam(k) + 100*camLoc(l) + tmax(m), '%04d');

                    for n=1:length(AoA) % for each angle of attack...

                        [pol, ~] = xfoil( nacaFoil , AoA(n) , Re(j) , Mach , 'ppar n 160' , 'oper iter 100' );
                        
                        S = b*c;
                        AR = b(i)/c(j);
                        CL = (pol.CL*eff*AR) / (eff*AR+2);
                       
                     %% Check constraints
                        % stability constraint
                        MH = (b(i)/2) * (pol.CD + CL^2/(pi*eff*AR));
                        % stress constraint
                        sigmaMAX = (210 * CL * qinf * S * b) / (32 * (tmax(m)/100)^2 * c^3);

                        if(MH <= RT && sigmaMAX <= sigmaYield/2.5)
                            data.viable(absIndex) = true;
                        end

                    %% Calculate emission
                        FT = FR - (CL*0.5*rho_air*Va^2*b(i)*c(j));
                        PT = FT*Vc/np;
                        FC = SFC*PT;
                        ECO2 = Fi*FC;

                    %% Store data
                        data.emission(absIndex) = ECO2;
                        data.foils(absIndex) = nacaFoil;
                        data.thickness(absIndex) = c(j)*tmax(m)/100;
                        data.span(absIndex) = b(i);
                        data.chord(absIndex) = c(j);
                        data.alpha(absIndex) = AoA(n);
                        data.Cl(absIndex) = pol.CL;
                        data.Cd(absIndex) = pol.CD;
                        data.stress(absIndex) = sigmaMAX;
                        data.stability(absIndex) = MH;

                        absIndex = absIndex + 1;
                    end
                end
            end
        end
    end
end
