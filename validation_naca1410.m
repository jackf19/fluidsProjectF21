clear
clc

myfoil='NACA1410';

load('naca1410_Re1.mat');
load('naca1410_Re2.mat');
load('naca1410_Re3.mat');

Re_c=[3e6 6e6 9e6];
Mach=0;

%% Re 1
alpha = naca1410_Re1.alpha;
[pol, ~] = xfoil(myfoil,alpha,Re_c(1),Mach,'ppar T 0.2','ppar n 300','oper iter 200');

figure(1)
t1 = tiledlayout(1,3);
t1.Title.String = "NACA1410 XFoil Analysis: Re = 3,000,000";
nexttile;

plot(pol.alpha, pol.CL, 'b');
hold on;
plot(naca1410_Re1.alpha, naca1410_Re1.CL, 'ro');
hold off;
title("CL vs Alpha"); xlabel("Alpha (deg)"); ylabel("CL");
grid on; grid minor;
nexttile;

plot(pol.alpha,pol.Cm, 'b');
hold on;
plot(naca1410_Re1.alpha, naca1410_Re1.Cm, 'ro');
hold off;
title("Cm c/4 vs Alpha"); xlabel("Alpha (deg)"); ylabel("Cm c/4");
grid on; grid minor;
nexttile;

plot(pol.alpha,pol.CD);
hold on;
plot(naca1410_Re1.alpha, naca1410_Re1.CD, 'ro');
hold off;
title("CD vs Alpha"); xlabel("Alpha (deg)"); ylabel("CD");
grid on; grid minor;

cl1 = pol.CL;
cm1 = pol.Cm;
cd1 = pol.CD;
alpha1 = pol.alpha;

%% Re 2
alpha = naca1410_Re2.alpha;
[pol, ~] = xfoil(myfoil,alpha,Re_c(2),Mach,'ppar T 0.2','ppar n 300','oper iter 200');

figure(2)
t2 = tiledlayout(1,3);
t2.Title.String = "NACA1410 XFoil Analysis: Re = 6,000,000";
nexttile;

plot(pol.alpha,pol.CL);
hold on;
plot(naca1410_Re2.alpha, naca1410_Re2.CL, 'ro');
hold off;
title("CL vs Alpha"); xlabel("Alpha (deg)"); ylabel("CL");
grid on; grid minor;
nexttile;

plot(pol.alpha,pol.Cm);
hold on;
plot(naca1410_Re2.alpha, naca1410_Re2.Cm, 'ro');
hold off;
title("Cm c/4 vs Alpha"); xlabel("Alpha (deg)"); ylabel("Cm c/4");
grid on; grid minor;
nexttile;

plot(pol.alpha,pol.CD);
hold on;
plot(naca1410_Re2.alpha, naca1410_Re2.CD, 'ro');
hold off;
title("CD vs Alpha"); xlabel("Alpha (deg)"); ylabel("CD");
grid on; grid minor;

cl2 = pol.CL;
cm2 = pol.Cm;
cd2 = pol.CD;
alpha2 = pol.alpha;

%% Re 3
alpha = naca1410_Re3.alpha;
[pol, ~] = xfoil(myfoil,alpha,Re_c(3),Mach,'ppar T 0.2','ppar n 300','oper iter 200');

figure(3)
t3 = tiledlayout(1,3);
t3.Title.String = "NACA1410 XFoil Analysis: Re = 9,000,000";
nexttile;

plot(pol.alpha,pol.CL);
hold on;
plot(naca1410_Re3.alpha, naca1410_Re3.CL, 'ro');
hold off;
title("CL vs Alpha"); xlabel("Alpha (deg)"); ylabel("CL");
grid on; grid minor;
nexttile;

plot(pol.alpha,pol.Cm);
hold on;
plot(naca1410_Re3.alpha, naca1410_Re3.Cm, 'ro');
hold off;
title("Cm c/4 vs Alpha"); xlabel("Alpha (deg)"); ylabel("Cm c/4");
grid on; grid minor;
nexttile;

plot(pol.alpha,pol.CD);
hold on;
plot(naca1410_Re3.alpha, naca1410_Re3.CD, 'ro');
hold off;
title("CD vs Alpha"); xlabel("Alpha (deg)"); ylabel("CD");
grid on; grid minor;

cl3 = pol.CL;
cm3 = pol.Cm;
cd3 = pol.CD;
alpha3 = pol.alpha;
