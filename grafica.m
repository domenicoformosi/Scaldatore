%% ---------------------------------------------------------
%% Animazione Scaldatore - Termometro

% 1. RECUPERO DATI E SICUREZZA TEMPORALE
tt_anim = 0:1e-5:2*T_star; 
% Controllo di sicurezza sulle dimensioni
if length(tt_anim) ~= length(y_tot)
    % Se non coincidono, usiamo il vettore temporale generato dallo step
    if exist('t_ww', 'var') && length(t_ww) == length(y_tot)
         tt_anim = t_ww;
    else
         tt_anim = linspace(0, 2*T_star, length(y_tot));
    end
end

% Visualizziamo la variazione y_tot.
T_vis = y_tot; 
% Definiamo i limiti della scala visiva in base ai dati
T_min_vis = min(T_vis) - 1; 
T_max_vis = max(T_vis) + 2;
range_T = T_max_vis - T_min_vis;

% 2. SETUP FIGURA
h_fig = figure('Name', 'Simulazione Riscaldatore', 'Color', 'w', 'Position', [50, 50, 1000, 700]);

%%%%%%%% QUADRANTE 1 (Alto Sx): SCALDATORE %%%%%%%%
subplot(2, 2, 1);
axis equal; view(3); 
axis([-0.5 2.5 -0.5 1.5 0 1.5]); axis off; hold on;
title('Riscaldatore', 'FontSize', 12);

% Blocco riscaldatore (Massa)
verts = [0 0 0; 2 0 0; 2 1 0; 0 1 0; 0 0 1; 2 0 1; 2 1 1; 0 1 1];
faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
h_block = patch('Vertices', verts, 'Faces', faces, 'FaceColor', 'b', 'FaceAlpha', 0.9, 'EdgeColor', 'k');
% Nota: FaceColor sarà aggiornato nel loop (in modo tale da fargli cambiare colore)

% Resistenze (Statiche, Grigio Scuro)
rod_x = linspace(0.4, 1.6, 4);
for i = 1:4
    plot3([rod_x(i) rod_x(i)], [0.5 0.5], [0.2 1.3], 'Color', [0.2 0.2 0.2], 'LineWidth', 3);
    plot3(rod_x(i), 0.5, 1.3, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
end

% Freccia aria in ingresso
quiver3(-0.8, 0.5, 0.5, 0.8, 0, 0, 'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
text(-1, 0.5, 0.5, sprintf('T_{in}'), 'Color', 'b', 'HorizontalAlignment','center');
% Freccia aria in uscita
quiver3(2.1, 0.5, 0.5, 0.8, 0, 0, 'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
text(2.7, 0.5, 0.5, sprintf('\\DeltaT_{out}'), 'Color', 'b', 'HorizontalAlignment','center');

%%%%%%%% QUADRANTE 2 (Alto Dx): TERMOMETRO %%%%%%%%
subplot(2, 2, 2);
axis equal; axis([-1 3 0 10]); axis off; hold on;
title('Misura \DeltaT_{out}', 'FontSize', 12);

% Disegno Vetro
rectangle('Position', [0, 0, 2, 2], 'Curvature', [1 1], 'FaceColor', [0.95 0.95 1], 'EdgeColor', 'k'); 
rectangle('Position', [0.5, 1.8, 1, 8], 'FaceColor', [0.95 0.95 1], 'EdgeColor', 'k'); 

% Disegno Liquido
rectangle('Position', [0.1, 0.1, 1.8, 1.8], 'Curvature', [1 1], 'FaceColor', 'r', 'EdgeColor', 'none'); 
h_liquid = rectangle('Position', [0.6, 1.8, 0.8, 0], 'FaceColor', 'r', 'EdgeColor', 'none'); 

% Tacche graduate (Calcolate dinamicamente)
y_start = 2; y_end = 10.5; 
h_max_stem = y_end - y_start; % Altezza massima fisica dello stelo
ticks = linspace(T_min_vis, T_max_vis, 6); % 6 tacche numeriche
y_ticks = linspace(y_start, y_end, 6);
for i = 1:6
    % Lineetta
    line([1.5, 1.8], [y_ticks(i) y_ticks(i)], 'Color', 'k', 'LineWidth', 1);
    % Numero
    text(2.0, y_ticks(i), sprintf('%.1f', ticks(i)), 'FontSize', 10);
end
% Testo grande col valore in tempo reale
h_text_temp = text(1, -1, '', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'r');

%%%%%%%% QUADRANTE 3 (Basso): GRAFICO TEMPORALE %%%%%%%%
subplot(2, 2, [3, 4]);
plot(tt_anim, T_vis, 'b', 'LineWidth', 1.5); hold on;
grid on; xlabel('Tempo [s]'); 
ylabel('\DeltaT_{out} [°C]'); % Etichetta aggiornata
title('Andamento Variazione Temperatura');
ylim([T_min_vis, T_max_vis]);
xlim([0, tt_anim(end)]);
h_marker = plot(tt_anim(1), T_vis(1), 'ro', 'MarkerFaceColor', 'r');

% Disegna una linea tratteggiata sul riferimento (W = 25)
yline(WW, 'k--', 'Riferimento'); 

% 3. CICLO ANIMAZIONE
cmap = jet(100); %serve per creare la mappa di colori per lo scaldatore (100 sono le sfumature generate)
anim_speed = 1; % velocità dell'animazione regolabile
pause(5); %pausa per visualizzare lo stato iniziale
for k = 1:anim_speed:length(tt_anim)
    if ~isvalid(h_fig), break; end
    
    cur_T = T_vis(k);
    cur_t = tt_anim(k);
    
    % --- AGGIORNAMENTO COLORE ---
    % Mappa la temperatura corrente sulla scala colori
    idx_col = round((cur_T - T_min_vis) / range_T * 99) + 1;
    if idx_col < 1, idx_col = 1; end; 
    if idx_col > 100, idx_col = 100; end
    col_current = cmap(idx_col, :);
    
    % Il blocco ora cambia colore gradualmente (visualizza l'inerzia termica)
    set(h_block, 'FaceColor', col_current);
    
    % --- AGGIORNAMENTO TERMOMETRO ---
    ratio = (cur_T - T_min_vis) / range_T;
    if ratio < 0, ratio = 0; end; if ratio > 1, ratio = 1; end
    set(h_liquid, 'Position', [0.6, 1.8, 0.8, ratio * h_max_stem]);
    set(h_text_temp, 'String', sprintf('%.1f', cur_T));
    
    % --- AGGIORNAMENTO GRAFICO ---
    set(h_marker, 'XData', cur_t, 'YData', cur_T);
    
    drawnow limitrate;
end