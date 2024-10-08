################################################################
### README.txt #################################################
################################################################

################################################################
## Adapted version of Vervoort et al. to run on Iridis for 
## Florent to explore results files
## Currently just for learning purposes!
################################################################

For:
'Earth System Model Analysis of how Astronomical Forcing is Imprinted onto the Marine Geological Record:
The Role of the Inorganic (Carbonate) Carbon Cycle and Feedbacks'
P. Vervoort, S. Kirtland Turner, F. Rochholz, A. Ridgwell

################################################################
06/15/2020 -- README.txt file creation (PV)
07/01/2021 -- update (AR)
07/23/2021 -- updated with new experiment names (PV)
09/11/2023 -- add note (L.28); update experiment names
14/02/2024 -- updated with reference directory (PV)
################################################################

Provided is the code used to create the model experiments presented in the paper.
Also given are the configuration files necessary to run these experiments.

The intention is to provide an opportunity to question the assumptions and
interpretation through re-analysis and the creation of new and different experiments.
(Plus, to provide a means to replicate results.)

All experiments are run from:
$HOME/cgenie.muffin/genie-main
(unless a different installation directory has been used)

### NOTE #########################################################
% 09/11/2023 - The manuscript has had some updates after publication
% in order to correct for an error in the insolation code. Commands 
% below are used to run the updated simulations with corrected code
#################################################################

### model experiments -- spinups ################################

The commands to run the spinups are listed as follows:

fkl_pp30 => hemispherically symmetric continental configuration with one continent from pole-to-pole
fkl_np30 => hemispherically asymmetric continental configuration with one continent in the NH

(1a) INITIAL SPINUP

The initial, 1st-stage closed system spin-up needs 20 kyr to reach equilibrium:

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_c.SPIN1 20000
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_c.SPIN1 20000

(1b) Second Stage SPINUP (part 1)

The follow-on, 2nd-stage (accelerated) open system spin-up requires a long spinup time of 1.5 Myr to reach equilibrium

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_c.SPIN2gl_a 750000 fkl_pp30_c.SPIN1
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_c.SPIN2gl_a 750000 fkl_np30_c.SPIN1

(1c) Second Stage SPINUP (part 2)

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_c.SPIN2gl_b 750000 fkl_pp30_c.SPIN2gl_a
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_c.SPIN2gl_b 750000 fkl_np30_c.SPIN2gl_a

### model experiments -- main ensemble ##########################

Below the commands to run the experiments with astronomical forcing for 4 Myr
Experiment 0-5 correspond to the numbering as described in the manuscript

(2a) For EXPERIMENT 0, no carbon cycle feedbacks:

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_EXP0_c.4Ma 4000000 fkl_pp30_c.SPIN2gl_b
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_EXP0_c.4Ma 4000000 fkl_np30_c.SPIN2gl_b

(2b) For EXPERIMENT 1, climate + ocean circulation + CO2-ocean chemistry feedbacks only:

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_EXP1_c.4Ma 4000000 fkl_pp30_c.SPIN2gl_b
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_EXP1_c.4Ma 4000000 fkl_np30_c.SPIN2gl_b

(2c) For EXPERIMENT 2, EXPERIMENT 1 + primary productivity feedbacks:

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_EXP2_c.4Ma 4000000 fkl_pp30_c.SPIN2gl_b
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_EXP2_c.4Ma 4000000 fkl_np30_c.SPIN2gl_b

(2d) For EXPERIMENT 3, EXPERIMENT 2 + CaCO3 sedimentation feedbacks:

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_EXP3_c.4Ma 4000000 fkl_pp30_c.SPIN2gl_b
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_EXP3_c.4Ma 4000000 fkl_np30_c.SPIN2gl_b

(2e) For EXPERIMENT 4, EXPERIMENT 3 + weathering feedbacks:

./runmuffin.sh muffin.CBSG.fkl_pp30.BASES_PV PUBS/published/vervoortetal.2024 fkl_pp30_EXP4_c.4Ma 4000000 fkl_pp30_c.SPIN2gl_b
./runmuffin.sh muffin.CBSG.fkl_np30.BASES_PV PUBS/published/vervoortetal.2024 fkl_np30_EXP4_c.4Ma 4000000 fkl_np30_c.SPIN2gl_b

################################################################
################################################################
################################################################