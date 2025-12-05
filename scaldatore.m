% Esempio progetto regolatore per sistema scaldatore
% 
% Controlli Automatici T
% Elisa Odorici
% Filippo del Duca
% Domenico Formosi

clear all; close all; clc
%% Parametri

h_r = 40; % [W/(m^2 C°)] Coefficiente di convezione tra riscaldatore e aria
A_r=0.13; % [m^2] Area di scambio termico tra riscaldatore e aria
c_r=858.8; % [J/(kg C°)] Calore specifico del riscaldatore
c_a=1010; % [J/(kg C°)] Calore specifico dell'aria
m_r=1.849; % [kg] Massa del riscaldatore
m_a=0.1041; % [kg] Massa dell'aria
mm_a=0.2; % [kg/s] Portata massica dell’aria
T_in=23; % [C°] Temperatura dell’aria in ingresso (ambiente a temperatura costante)
k=25*1e3; % [1/C°] Coefficiente di variazione della resistenza con la temperatura
x1_e=190; 
x2_e=78;

%% Coppia di equilibrio
x_e = [x1_e,x2_e];
u_e = 859.04; % [W]

%% Funzione di Trasferimento 

A = [(-h_r*A_r)/(m_r*c_r)-(ue*k)/(m_r*c_r*(1+k*x1_e)^2), (h_r*A_r)/(m_r*c_r) ;
     (h_r*A_r)/(m_a*c_a), (-mm_a/m_a)-(h_r*A_r)/(m_a*c_a)];
B = [1/(m_r*c_r*(1+k*x1_e));0];

C = [0 1];

D = 0;

modello=ss(A,B,C,D);

GG=tf(modello);

bode(GG);
%%G=6.557e-12
 %% ------------------------
%  s^2 + 1.974 s + 0.006291
sys=zpk(zero(G),pole(G),dcgain(G));%%forma di Bode

%% Specifiche 

% ampiezze gradini
WW = ;
DD = ;

% errore a regime
e_star = ;

% attenuazione disturbo sull'uscita
A_d = ;
omega_d_min = ;
omega_d_MAX = ;

% attenuazione disturbo di misura
A_n = ;
omega_n_min = ;
omega_n_MAX = ;

% Sovraelongazione massima e tempo d'assestamento all'1%
S_star = 6;
T_star = 0.1;

% Margine di fase
Mf_esp = 45;

%% Diagramma di Bode

figure(1);
bode(GG,{omega_plot_min,omega_plot_max});
grid on, zoom on;


%% Regolatore statico - proporzionale senza poli nell'origine

% valore minimo prescritto per L(0)
mu_s_error = ;
mu_s_dist  = ;

% guadagno minimo del regolatore ottenuto come L(0)/G(0)
G_0 = ;
G_omega_d_MAX = ;


RR_s = ; 

% Sistema esteso
GG_e = ;
