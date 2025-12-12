# 2526_ESE_TP1_FPGA_MBENGUE_SAINT-FLEUR
# Compte Rendu – TP1 FPGA 

## 1. Introduction
Ce TP avait pour objectif de découvrir la chaîne de développement FPGA avec Quartus Prime Lite : création de projet, description VHDL, contraintes, compilation, programmation sur la carte DE10-Nano et mise en œuvre d’éléments séquentiels et combinatoires.  
Une seconde partie consistait à réaliser progressivement un mini-projet : un « écran magique » utilisant la sortie HDMI, les encodeurs et une mémoire vidéo.

---

## 3. TP1 – Prise en main de Quartus

### 3.1 Création du projet
- Nouveau projet nommé `TP1_FPGA`.
- Choix du FPGA **5CSEBA6U23I7**.

Le code fourni fonctionne en logique inverse. On le modifie donc pour que la Led s'allume quand on appuie sur l'encodeur :
```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity tuto_fpga is
    port (
        pushl : in std_logic;
        led0  : out std_logic
    );
end entity;

architecture rtl of tuto_fpga is
begin
    led0 <= '1' WHEN pushl='1';
    ELSE '0';
end architecture;
```

<img width="400" src="https://github.com/user-attachments/assets/1acc939a-4563-42d2-8098-f2157437cbbe">

<img width="400" src="https://github.com/user-attachments/assets/88d97b60-e692-49b1-9bbc-247d9402addb">

### Faire clignoter une LED
1) L'horloge nommée FPGA_CLK1_50 est connectée sur la broche V11.

3) Schéma proposé par quartus:

<img width="499" height="488" alt="image" src="https://github.com/user-attachments/assets/f9500782-cc76-4261-a21a-eb3d43ffa6a9" />

6) On fait clignoter la led :

https://github.com/user-attachments/assets/0d36cc00-006d-4b81-8d19-2c59da1fe209

8) Schéma proposé par quartus :

<img width="483" height="208" alt="image" src="https://github.com/user-attachments/assets/387b3933-288c-4c04-957c-c4bd5cf8a752" />

11) _n signifie active low ie le signal est actif à l’état bas.

### Chenillard
Voici notre chenillard

https://github.com/user-attachments/assets/13af2a37-8c67-4c30-ba2a-02d5275525b1


