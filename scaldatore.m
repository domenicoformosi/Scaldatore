% Esempio progetto regolatore per sistema scaldatore
% 
% Controlli Automatici T
% Elisa Odorici
% Filippo del Duca
% Domenico Formosi

clear all; close all; clc

omega_plot_min = 1e-2;
omega_plot_max = 1e5;

%% Parametri
%solo per visualizzione, pulsazione minima e massima

h_r = 40; % [W/(m^2 C°)] Coefficiente di convezione tra riscaldatore e aria
A_r=0.13; % [m^2] Area di scambio termico tra riscaldatore e aria
c_r=858.8; % [J/(kg C°)] Calore specifico del riscaldatore
c_a=1010; % [J/(kg C°)] Calore specifico dell'aria
m_r=1.849; % [kg] Massa del riscaldatore
m_a=0.1041; % [kg] Massa dell'aria
mm_a=0.2; % [kg/s] Portata massica dell’aria
T_in=23; % [C°] Temperatura dell’aria in ingresso (ambiente a temperatura costante)
k=2.5*1e-3; % [1/C°] Coefficiente di variazione della resistenza con la temperatura
x1_e=190; 
x2_e=27.1911;

%% Coppia di equilibrio
x_e = [x1_e;x2_e];


ue = (h_r*A_r)*(x_e(1) - x_e(2))*(1 + k*x_e(1)); % [W]

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
damp(GG);
sys=zpk(zero(GG),pole(GG),dcgain(GG));%%forma zeri e poli

%% Specifiche 

% ampiezze gradini
WW = 25;
DD = 4;

% errore a regime
e_star = 0.0035;

% attenuazione disturbo sull'uscita
A_d = 48;
omega_d_min = 0;
omega_d_MAX = 0.2;

% attenuazione disturbo di misura
A_n = 80 ;
omega_n_min = 1e4;
omega_n_MAX = 1.5*1e7;

% Sovraelongazione massima e tempo d'assestamento all'1%
S_star = 6;
T_star = 0.1;

% Margine di fase
Mf_esp = 45;

%% Diagramma di Bode della G

figure(1);
bode(GG,{omega_plot_min,omega_plot_max});
grid on, zoom on;


%% Regolatore statico

% valore minimo prescritto per L(0)
mu_s_error =(DD+WW)/e_star;
mu_s_dist  = 10^(A_d/20);

% guadagno minimo del regolatore ottenuto come L(0)/G(0)
G_0 = abs(evalfr(GG,0));

G_omega_d_MAX = abs(evalfr(GG,1j*omega_d_MAX));


RR_s = max(mu_s_error/G_0,mu_s_dist/G_omega_d_MAX); 

% Sistema esteso
GG_e = RR_s*GG;

%% Diagrammi di Bode di Ge con specifiche
figure('Name','Diagramma di Bode di G_e','NumberTitle','off')
hold on;

% Calcolo specifiche S% => Margine di fase
xi_star = abs(log(S_star/100))/sqrt(pi^2 + log(S_star/100)^2);
Mf_min  = max(xi_star*100,Mf_esp);

% Specifiche su d
Bnd_d_x = [omega_plot_min; omega_d_MAX; omega_d_MAX; omega_plot_min];
Bnd_d_y = [A_d; A_d; -150; -150];
patch(Bnd_d_x, Bnd_d_y,'r','FaceAlpha',0.2,'EdgeAlpha',0);

% Specifiche su n
Bnd_n_x = [omega_n_min; omega_n_MAX; omega_n_MAX; omega_n_min];
Bnd_n_y = [-A_n; -A_n; 100; 100];
patch(Bnd_n_x, Bnd_n_y,'g','FaceAlpha',0.2,'EdgeAlpha',0);

% Specifiche tempo d'assestamento (minima pulsazione critica)
omega_Ta_min = 1e-4; % lower bound per il plot
omega_Ta_max = 460/(Mf_min*T_star); % omega_c >= 460/(Mf*T^*) ~ 4.6
Bnd_Ta_x = [omega_Ta_min; omega_Ta_max; omega_Ta_max; omega_Ta_min];
Bnd_Ta_y = [0; 0; -150; -150];
patch(Bnd_Ta_x, Bnd_Ta_y,'b','FaceAlpha',0.2,'EdgeAlpha',0);


% Specifiche sovraelongazione (margine di fase)
omega_c_min = omega_Ta_max;
omega_c_max = omega_n_min;

phi_up = Mf_min - 180;
phi_low = -270; % lower bound per il plot

Bnd_Mf_x = [omega_c_min; omega_c_max; omega_c_max; omega_c_min];
Bnd_Mf_y = [phi_up; phi_up; phi_low; phi_low];
patch(Bnd_Mf_x, Bnd_Mf_y,'g','FaceAlpha',0.2,'EdgeAlpha',0);

% Plot Bode G_e con margini di stabilità
margin(GG_e,{omega_plot_min,omega_plot_max});


grid on; zoom on;



Mf_star = Mf_min+5;
omega_c_star = 120;

mag_omega_c_star = abs(evalfr(GG_e,j*omega_c_star));
arg_omega_c_star    = rad2deg(angle(evalfr(GG_e,j*omega_c_star)));

M_star = 1/mag_omega_c_star;
phi_star = Mf_star - 180 - arg_omega_c_star;

tau = (M_star - cos(phi_star*pi/180))/(omega_c_star*sin(phi_star*pi/180));
alpha_tau = (cos(phi_star*pi/180) - 1/M_star)/(omega_c_star*sin(phi_star*pi/180));
alpha = alpha_tau / tau;

if min(tau,alpha) < 0
    fprintf('Errore: parametri rete anticipatrice negativi');
    return;
end

s=tf("s");
R_high_frequency = 1/(1 + s/2e3);

RR_d = (1 + tau*s)/(1 + alpha * tau*s)*R_high_frequency;

RR = RR_s*RR_d;

LL = RR*GG; % funzione di anello
% plot funzione ad anello senza polo ad hf
figure('Name','Diagramma di Bode di L senza polo','NumberTitle','off')
hold on;
patch(Bnd_d_x, Bnd_d_y,'r','FaceAlpha',0.2,'EdgeAlpha',0);
patch(Bnd_n_x, Bnd_n_y,'g','FaceAlpha',0.2,'EdgeAlpha',0);
patch(Bnd_Ta_x, Bnd_Ta_y,'b','FaceAlpha',0.2,'EdgeAlpha',0);
margin(LL/R_high_frequency,{omega_plot_min,omega_plot_max});
patch(Bnd_Mf_x, Bnd_Mf_y,'r','FaceAlpha',0.2,'EdgeAlpha',0);
grid on; zoom on;
% plot funzione ad anello con polo ad hf
figure('Name','Diagramma di Bode di L con polo','NumberTitle','off');
hold on;
patch(Bnd_d_x, Bnd_d_y,'r','FaceAlpha',0.2,'EdgeAlpha',0);
patch(Bnd_n_x, Bnd_n_y,'g','FaceAlpha',0.2,'EdgeAlpha',0);
patch(Bnd_Ta_x, Bnd_Ta_y,'b','FaceAlpha',0.2,'EdgeAlpha',0);
margin(LL,{omega_plot_min,omega_plot_max});
patch(Bnd_Mf_x, Bnd_Mf_y,'r','FaceAlpha',0.2,'EdgeAlpha',0);
grid on; zoom on;


mf_att=rad2deg(angle(evalfr(LL,1j*omega_c_star)))+180; % che è questo ??




%% Definizione funzione di sensitività e sentività complementare
SS=1/(1+LL);

FF=LL/(1+LL);

%% Plot disturbo in uscita
figure('Name','Attenuazione disturbo in uscita','NumberTitle','off')
tt = 0:1e-2:2e2;
dd=0;
termine_k=0;

for k=1:3
    termine_k=2*sin(k*0.05*tt);
    dd=dd+termine_k;
end   

y_dd=lsim(SS,dd,tt);

hold on, grid on, zoom on
plot(tt,y_dd,'b-'); % per plottare con scala diversa generare un altro segnale atrimenti non va la somma
plot(tt,dd,'r--');
grid on
legend('y_d(t)',"d(t)");

%% Plot disturbo di misurazione
figure('Name','Attenuazione disturbo di misurazione','NumberTitle','off')
tt = 0:1e-5:2*1e-3;
termine_k=0;
nn=0;

for k=1:5
    termine_k=0.5*sin(k*1e5*tt);
    nn=nn+termine_k;
end 


y_nn=lsim(-FF,nn,tt);
hold on, grid on, zoom on
plot(tt,y_nn,'b-');
plot(tt,nn,'r--');
legend('y_n(t)',"n(t)");

%% PLot uscita totale 

% ridefinisco il segnale di disturbo di misurazione con stesso vettore di tempi
tt = 0:1e-5:2*T_star;
termine_k=0;
nn=0;

for k=1:5
    termine_k=0.5*sin(k*1e5*tt);
    nn=nn+termine_k;
end 


y_nn=lsim(-FF,nn,tt);

% ridefinisco il segnale di disturbo in uscita con stesso vettore di tempi
tt = 0:1e-5:2*T_star;
%tt = 0:1e-2:2e2;
dd=0;
termine_k=0;

for k=1:3
    termine_k=2*sin(k*0.05*tt);
    dd=dd+termine_k;
end   

y_dd=lsim(SS,dd,tt);


tt = 0:1e-5:2*T_star;
F = (WW * LL) / (1 + LL);
figure(6)
[y_ww,t_ww] = step(F,tt);
y_tot = y_nn + y_dd +y_ww; %importante
%y_not = y_ww + dd + nn; %% se non commenti questa cosa implode matlab (e il tuo computer con esso)s

tt = 0:1e-1:2e2;
figure('Name','Uscita Totale','NumberTitle','off')
plot(t_ww,y_tot,'b');
%plot(t_ww,y_not,'r--');



%%--------------------------------

grid on, zoom on, hold on;

T_simulation = 2*T_star;

LV = evalfr(WW*FF,0);

% vincolo sovraelongazione
patch([0,T_simulation,T_simulation,0],[LV*(1+S_star/100),LV*(1+S_star/100),LV*2,LV*2],'r','FaceAlpha',0.3,'EdgeAlpha',0.5);

% vincolo tempo di assestamento all'1%
patch([T_star,T_simulation,T_simulation,T_star],[LV*(1-0.01),LV*(1-0.01),0,0],'g','FaceAlpha',0.1,'EdgeAlpha',0.5);
patch([T_star,T_simulation,T_simulation,T_star],[LV*(1+0.01),LV*(1+0.01),LV*2,LV*2],'g','FaceAlpha',0.1,'EdgeAlpha',0.1);

ylim([0,LV*2]);

[y_step,t_step] = step(WW*FF, T_simulation);
plot(t_step,y_step,'b');

Legend_step = ["Risposta al gradino"; "Vincolo sovraelongazione"; "Vincolo tempo di assestamento"];
legend(Legend_step);