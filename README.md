## ⚙️ Progetto: Sistema di Controllo per Riscaldatore Elettrico

Questo repository contiene la modellazione, l'analisi e la sintesi di un sistema di controllo in retroazione per un riscaldatore elettrico per l'aria, come parte del corso di Controlli Automatici (CAT).

---

## 🚀 Panoramica del Sistema

Il progetto si concentra sul controllo della temperatura dell'aria in uscita ($T_{out}$) agendo sulla potenza elettrica ($P_E$) fornita al riscaldatore. Il sistema è intrinsecamente non lineare e viene gestito tramite l'approccio classico della linearizzazione attorno ad un punto di equilibrio.

### Modello Dinamico

Il sistema è descritto da due equazioni differenziali che modellano l'evoluzione della temperatura del riscaldatore ($T_R$) e della temperatura dell'aria in uscita ($T_{out}$).

| Variabile di Stato | Descrizione |
| :--- | :--- |
| $x_1 = T_R$ | Temperatura del riscaldatore |
| $x_2 = T_{out}$ | Temperatura dell'aria in uscita |
| $u = P_E$ | Potenza elettrica (Ingresso di controllo) |
| $y = T_{out}$ | Temperatura dell'aria in uscita (Uscita misurata) |

---

## 📁 Struttura del Repository

* `scaldatore.m`: Script MATLAB contenente i parametri fisici, il calcolo della coppia di equilibrio ($x_e, u_e$), la linearizzazione, la sintesi del regolatore ($R(s)$) e le simulazioni sul sistema linearizzato.
* `sistema_non_linearizzato.slx`: Modello Simulink utilizzato per testare il regolatore sul sistema non lineare, implementando la logica di controllo in deviazione.
* `relazione.pdf`: Documento finale di progetto (derivato da `relazione.tex`) con analisi teoriche, mappatura delle specifiche e risultati delle simulazioni.

---

## 🛠️ Requisiti di Esecuzione

Per eseguire le simulazioni e riprodurre i risultati:

1.  **Software:** MATLAB/Simulink (Versione R2023a o successiva consigliata).
2.  **Ordine di Esecuzione:**
    * Eseguire prima lo script **`scaldatore.m`** per definire il regolatore `RR` e tutte le costanti (`x_e`, `u_e`, `C`, ecc.) nel Workspace di MATLAB.
    * Aprire e simulare il modello **`sistema_non_linearizzato.slx`**.

### 📝 Nota Cruciale per Simulink

Il modello Simulink implementa una logica di controllo in deviazione ($\delta u = u - u_e$) e deve partire dall'equilibrio:

* **Condizione Iniziale Integratore:** Deve essere impostata a **`x_e`** (ovvero `[190; 78]`).
* **
