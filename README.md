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

2) Notre schéma :

<img width="466" height="200" alt="image" src="https://github.com/user-attachments/assets/6346586b-656f-4260-912a-9ae1df243b96" />

4) Schéma proposé par quartus:

<img width="499" height="488" alt="image" src="https://github.com/user-attachments/assets/f9500782-cc76-4261-a21a-eb3d43ffa6a9" />

6) On fait clignoter la led :

https://github.com/user-attachments/assets/0d36cc00-006d-4b81-8d19-2c59da1fe209

7) Notre schéma :

<img width="529" height="249" alt="image" src="https://github.com/user-attachments/assets/94570453-fdbc-443c-af33-27ba3aaa1aa7" />


8) Schéma proposé par quartus :

<img width="483" height="208" alt="image" src="https://github.com/user-attachments/assets/387b3933-288c-4c04-957c-c4bd5cf8a752" />

11) _n signifie active low ie le signal est actif à l’état bas.

### Chenillard
Voici notre chenillard

https://github.com/user-attachments/assets/13af2a37-8c67-4c30-ba2a-02d5275525b1

## Petit projet : Ecran magique
### Gestion des encodeurs 
2) D1 : première bascule D, D2: deuxieme bascule D

D1.D reçoit A, D1.Q = l’état de A au cycle précédent

D2.D reçoit aussi A, D2.Q = l’état de A au cycle courant

Le composant logique à utiliser est un XOR qui prroduit une impulsion quand A change d’état

4)

<img width="700" height="541" alt="image" src="https://github.com/user-attachments/assets/32618eae-b96c-482d-9bc7-f5a9f87c801e" />

Test sur la carte : 

https://github.com/user-attachments/assets/46a03e3a-17aa-4312-88cc-c4e1e3271e07

### Contrôleur HDMI : 

5) on utilise le format RGB 8:8:8, les bits de 23 à 16 correspondent au rouge, de 15 à 8 au vert et le reste (bleu) est mis à 0.

<img width="638" height="551" alt="image" src="https://github.com/user-attachments/assets/cc3dd50e-0469-4563-ab63-ae356c00735a" />

### Déplacement d'un pixel : 

On a fait un carré de pixel blanc pour mieux le voir se déplacer : 



https://github.com/user-attachments/assets/f8702084-16fb-4aa1-889c-a3a4f12caf99


### Mémorisation : 

1) Une mémoire dual-port est une mémoire qui permet d’effectuer deux accès indépendants simultanés :

Chaque port possède ses propres signaux d’adresse, de données et de contrôle.

Port A peut lire ou écrire une cellule mémoire pendant qu’un autre accès se produit sur Port B.

On peut donc faire : 

Port A : écriture des pixels venant des encodeurs (dessin)

Port B : lecture des pixels par le contrôleur HDMI (affichage)

2)

<img width="401" height="458" alt="image" src="https://github.com/user-attachments/assets/f442a4df-3704-4183-9d9d-5e3232400e02" />

3) On réussit à faire un dessin :

<img width="217" height="111" alt="image" src="https://github.com/user-attachments/assets/116828c8-6aaa-4e4e-afd8-3a57f49ea703" />

### Effacement : 
1) On souhaiterait faire un effacement progressif : on doit donc balayer toutes les adresses tout en bloquant temporairement les écritures normales. On doit donc introduire une notion d'état, un compteur, une priorité sur l'écriture.
On a donc ajouté pour l'appui sur le bouton de l'encodeur gauche une machine d'état simple. Lorsqu'on appuie, un signal est généré et déclenche la machine d'état qui passe de l'état IDLE à l'état CLEARING. Dans l'état CLEARING, un compteur parcourt toutes les adresses de la RAM. A chaque cycle d'horloge, la donnée écrite est mise à zéro, ce qui efface progressivement le framebuffer. Une fois cela terminé, la machine revient à l'état IDLE et l'écriture normale peut reprendre.

3) 

https://github.com/user-attachments/assets/40daa5cf-f84e-4f94-ac62-affe3b69ba44


