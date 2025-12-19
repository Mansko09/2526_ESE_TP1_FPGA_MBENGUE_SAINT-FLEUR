# sim.do - Script de simulation pour l'encodeur

# Création/suppression de la bibliothèque de travail
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compilation des fichiers (ajuste les chemins si nécessaire)
# Assure-toi que les fichiers rising_edge_detect.vhd et falling_edge_detect.vhd existent
vcom -2008 rising_edge_detect.vhd
vcom -2008 falling_edge_detect.vhd
vcom -2008 encoder.vhd
vcom -2008 encoder_tb.vhd

# Lancement de la simulation
vsim -voptargs="+acc" work.encoder_tb

# Ajout des signaux intéressants à l'affichage
add wave -r /*
add wave -label "A rising"  /DUT/a_rising
add wave -label "A falling" /DUT/a_falling
add wave -label "B rising"  /DUT/b_rising
add wave -label "B falling" /DUT/b_falling
add wave -label "S_int"     /DUT/S_int

# Configuration de l'affichage
configure wave -timelineunits ns
configure wave -signalnamewidth 1

# Lancement de la simulation
run 1 us

# Zoom complet
wave zoom full