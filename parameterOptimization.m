clear; clc; dfs;
%% Given
W = 20000*907.185; %(*displacement: ton \[Rule] kg*) 
T_sea = 15 + 273; %(*water temperature: \[Degree]C \[Rule] K*)
rho_sea = 1025; %(*water density: kg/m^3*)
mu_sea = 0.00122; %(*water viscosity: Ns/m^2*)
rho_air = 1.225; %(*air density: kg/m^3*)
mu_air = 1.7894e-5; %(*air viscosity: Ns/m^2*)
p_atm = 101325; %(*atmospheric pressure: Pa*)
A = 20000; %(*hull wetted area: m^2*)
SFC = 168; %(*specific fuel consumption: g/kWh*)
Fi = 2.75; %(*CO2 intensity of fuel: gCO2/gfuel*)
L = 200; %(*ship length: m*)
Cw = 3*10^-4; %(*wave-making resistance coefficient*)
Vc = 19/1.94384; %(*cruise velocity: kt \[Rule] m/s*)
Va = 60/1.94384; %(*apparent wind speed: kt \[Rule] m/s*)
np = 0.5; %(*propulsive efficiency*)
h = 0.00125; %(*righting lever arm: m*)
eff = 0.9; %(*span efficiency factor*)
sigma_y = 100*10^6; %(*yield strength: Pa*)
g = 9.81; %(*m/s^2*)


Mach = Va/sqrt(T_sea*1.4*287);
c = 2:2:20;
Re = (rho_air*Va*c)/mu_air;
alpha = 0:2:12;
foils = 'naca1410';
Cl=zeros(1,length(alpha)*length(c));
Cd=zeros(1,length(alpha)*length(c));
absCount = 1;

for i=1:length(c)
    [pol, ~] = xfoil(foils,alpha,Re(i),Mach,'ppar T 0.2','ppar n 300','oper iter 200');
    Cl(absCount) = max(pol.CL);
    Cd(absCount) = min(pol.CD);
    absCount = absCount + 1;
end
