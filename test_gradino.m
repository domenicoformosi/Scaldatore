% --- Esplorare il range di ampiezza di riferimenti a gradino tali per cui il controllore rimane efficace sul sistema non lineare ---
modelName = 'sistema_non_linearizzato';
% paramValues = [25,35,45,55,65,75,85,90,100]; 
paramValues = [0,-10,-20];
T_simulation = 50;
hold on;                           


for i = 1:length(paramValues)
   
    % recupero il valore dall'array e lo metto al posto del gradino di
    % riferimento
    WW = paramValues(i); 
    
    % eseguo simulazione contenuta in simulink
   
    simOut = sim(modelName);
    
    % estraggo dati dal blocco out inserito in simulink 
    t = simOut.tout;
    y = squeeze(simOut.yout.getElement(1).Values.Data); 
    % rimuove arrayi di dimensioni uno, necessario per far funzionare il
    % plot

    
    % 4. Plot dell'i-esimo grafico
    plot(t, y, 'LineWidth', 1.5, 'DisplayName', ['Ampiezza = ' num2str(WW)]);
end
% --- LegendAa ---
grid on;
% specifica Ta
xline(0.08, '--r', 'Limite Ta', 'LineWidth', 1.5,'DisplayName', ['Limite Ta = ' num2str(0.08)]);
xlabel('Tempo [s]');
ylabel('Uscita');
title('Confronto Risposte al variare dell ingresso');
legend show;