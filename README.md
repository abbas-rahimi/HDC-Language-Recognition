We provide Matlab and VERILOG RTL implemntations for a language recognition algorithm 
using hyperdimensional computing. 

These programs are licensed as GNU GPLv3.

For MATLAB code, there are basically two main functions:

1. buildLanguageHV (N, D): that is a training function. 
D is the dimension of hypervectors (in the order of 10K) and N is the size of N-grams (from unigrams to e.g., pentagrams).
This function returns [iM, langAM]. iM is an item memory where hypervectors are stored. 
langAM is a memory where language hypervectors are stored and can be used as an associative memory.

2. test (iM, langAM, N, D): that is a test function.
This test function tests unseen sentences and tries to recognizes their languages by querying into langAM.
 
Here is a simple example of using algorithm:

>> langRecognition
>> D = 10000;
>> N = 4;
>> [iM, langAM] = buildLanguageHV (N, D);
Loaded traning language file ../training_texts/afr.txt
Loaded traning language file ../training_texts/bul.txt
... 
% Please be patient it will take a while to lead all languages

>> accuracy = test (iM, langAM, N, D)
Loaded testing text file ../testing_texts/pl_715_p.txt
Loaded testing text file ../testing_texts/pl_716_p.txt
....
accuracy =  0.9783


The RTL code is written in synthesizable Verilog. The source files are available at ./Verilog/RTL.
There is also a simulation script using ModelSim in ./Verilog/model-sim.

>> cd ./Verilog/model-sim
>> source rtl.tcl

# Sims started
# Memory loading is done!
# end of test file ../../testing_texts/bg_910_p.txt is reached
# end of test file ../../testing_texts/bg_911_p.txt is reached
...
# numTests=        100 correct=         95 for              4683557

Please let us know if you face any problem or discover any bugs!
For more info, you can read and cite our paper, A. Rahimi, P. Kanerva, and J. M. Rabaey "A Robust and Energy-Efficient Classifier Using Brain-Inspired Hyperdimensional Computing," In ACM/IEEE International Symposium on Low-Power Electronics and Design (ISLPED), 2016.

Thanks!

Abbas Rahimi
email: abbas@eecs.berkeley.edu
