%% ------- FLUIDS FALL 2021 AIRFOIL OPTIMIZATION ------- %%
% Author: Jack Fox (jackf19)
% Version 3 (12/2/21)
clear; clc; dfs;

%% Given values (do not change)
W = 20000 * 907.185;        % displacement: ton -> kg
rho_sea = 1025;             % water density: kg/m^3
mu_sea = 0.00122;           % water viscosity: Ns/m^2
rho_air = 1.225;            % air density: kg/m^3
mu_air = 1.7894e-5;         % air viscosity: Ns/m^2
p_atm = 101325;             % atmospheric pressure: Pa
A = 20000;                  % hull wetted area: m^2
SFC = 168 / (3600*10^6);    % specific fuel consumption: kg/Ws
Fi = 2.75;                  % CO2 intensity of fuel: gCO2/gfuel
L = 200;                    % ship length: m
Cw = 3*10^-4;               % wave-making resistance coefficient
Vc = 19 / 1.94384;          % cruise velocity: kt -> m/s
Va = 60 / 1.94384;          % apparent wind speed: kt -> m/s
np = 0.5;                   % propulsive efficiency
h = 0.00125;                % righting lever arm: m
eff = 0.9;                  % span efficiency factor
sigmaYield = 100*10^6;      % yield strength: Pa
g = 9.81;                   % m/s^2

%% VARIABLE PARAMETERS %%
b = [40 45]; % <-- run with your specified range of span
%c = 4:2:12;
cam = 2:4; % do not change
camLoc = 2:4; % do not change
%tmax = 4:12; % must be <= 12
%AoA = 4:2:12;

c = [4 8];
tmax = 6; % must be <= 12
AoA = [4 6];

%% Preliminary Calculations (do not change) 
ReL = (rho_sea * Vc * L)/mu_sea;
Cf = (0.0059 * 1.25) / (ReL^(0.2));
FR = (Cf + Cw) * 0.5 * rho_sea * Vc^2 * A; % water resistance

qinf = 0.5 * rho_air * Va^2;
RT = h * W * g; % righting torque

Re = (rho_air * Va * c)/mu_air; % vector of Re for each chord length
Mach = 0;

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

% Loop through all parameters
absIndex = 1;
errorCount = 0;
for i=1:length(b)  % for each span...
    for j=1:length(c)  % for each chord...
        for k=1:length(cam)  % for each max camber...
            for l=1:length(camLoc)  % for each max camber location...
                for m=1:length(tmax) % for each thickness...
                    
                    % generate NACA string using camber and thickness i.e. "NACA2412"
                    nacaFoil = convertStringsToChars(append("NACA", num2str(1000*cam(k) + 100*camLoc(l) + tmax(m), '%04d')));

                    for n=1:length(AoA) % for each angle of attack...
                        try
                            [pol, foil, converged] = xfoil( nacaFoil , AoA(n) , Re(j) , Mach , 'ppar n 160' , 'oper iter 100' );
                        catch
                            fprintf("INVALID AIRFOIL   %s\n", nacaFoil);
                            errorCount = errorCount + 1;
                            absIndex = absIndex + 1;
                            continue;
                        end

                        if (~converged)
                            fprintf("NOT CONVERGED    run case %d\n", absIndex);
                            absIndex = absIndex + 1;
                            continue;
                        end
                        fprintf("converged        run case %d\n", absIndex);
                        
                        S = b(i) * c(j);
                        AR = b(i) / c(j);
                        CL = (pol.CL * eff * AR) / (eff * AR + 2);
                       
                     %% Check constraints
                        % stability constraint
                        D = (pol.CD + CL^2/(pi*eff*AR)) * qinf * S;
                        MH = (b(i)/2) * D; % heeling moment, N*m

                        % stress constraint
                        sigmaMAX = (210 * CL * qinf * S * b(i)) / (32 * (tmax(m)/100)^2 * c(j)^3); % maximum root stress, Pa

                        if(MH <= RT && sigmaMAX <= sigmaYield/2.5)
                            data.viable(absIndex) = true;
                        end

                    %% Calculate emission
                        FT = FR - (CL*0.5*rho_air*Va^2*b(i)*c(j));
                        PT = FT*Vc/np;
                        FC = SFC*PT;
                        ECO2 = Fi*FC*3600;

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

%% ------ CHANGE THE OUTPUT FILENAME OR YOUR DATA MAY BE OVERWRITTEN ------ %%
data = sortrows(data,'emission','ascend');
%filename = "jackData_b40-45.txt";
filename = "testV3.txt";
writetable(data, filename, 'delimiter', '\t');