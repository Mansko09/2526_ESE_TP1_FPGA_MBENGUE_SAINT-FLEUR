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
- Ajout d’un fichier VHDL minimal :

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
    led0 <= pushl;
end architecture;
```
Ce code fonctionne en logique inverse. On le modifie donc pour que la Led s'allume quand on appuie sur l'encodeur :
![image](https://github.com/user-attachments/assets/1acc939a-4563-42d2-8098-f2157437cbbe)

![image](https://github.com/user-attachments/assets/88d97b60-e692-49b1-9bbc-247d9402addb)

### Faire clignoter une LED

<img width="499" height="488" alt="image" src="https://github.com/user-attachments/assets/f9500782-cc76-4261-a21a-eb3d43ffa6a9" />

