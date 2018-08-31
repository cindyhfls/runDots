RunDots README
% harrison ritz 2018 -- harrison.ritz@gmail.com


TASK
participants perform a simon-like task. Dot color indicates a response hand, with dot motion that is congruent (same direction as response hand) or incongruent (different direction as response hand). Dot motion coherence (and direction) modulates the degree of conflict between motion and color.


VERSIONS
Task version
SAME: conflict changes randomly over trials, no SOA
SOA: conflict drifts up and down over trials, 225-275ms SOA

Color
TEUF: teufel colors;  isoluminant, equally  detectable, and perceptually equidistant
ISOLUM: isoluminant & equidistant in HSL color space


RUN
execute 'runDots.m'. 
Can set participant & some experiment parameters in the dialog box. 
Will have color training, motion training, and then the main experiment, which alternates between long blocks of attend-color, and short blocks of attend-motion. 
Need to instruct participants at the beginning of color training, motion training, and then the beginning of the main experiment.
At any point, press ‘q’ in during dot motion to quit and save the experiment.


EDIT PARAMETERS
most of the parameters are in expParam function, including trial/block number. Can change dialog defaults in expParam (out.defualt) for common parameters (e.g., monitor width). Some dot motion parameters are in getDotInfo function. 
NOTE: you must set expParam parameters seperately for each version of the task (i.e., 'same' vs 'soa').

~20 minute version: 
50*1 motion training, 50*1 color training, 90*4 attend-color, 30*3 attend motion. (randBl = 7)

~60 minute version: 
100*1 motion training, 100*1 color training, 100*12 attend-color, 30*11 attend-motion. (randBl = 23)


SUGGESTED INSTRUCTIONS
motion training: 'you will see dots that are moving left or right. if the dots are moving left, respond with the left key. if the dots are moving right, respond with the right key. If you are correct, you will be told so, and if you make a mistake, you will be reminded about the task. As always, please respond as quickly and accurately as you can.'

color training: 'you will see dots that are one of *these* four colors. if the dots are *these1* colors, respond with *this1* hand. if the dots are *these2* colors, respond with *this2* hand. If you are correct, you will be told so, and if you make a mistake, you will get to see the colors again. As always, please respond as quickly and accurately as you can.'

main experiment: 'This is the main section. Now you will see dots that both have a color, and are moving left or right. There will be two kinds of blocks. This block is a color block. In this block, you will have to respond to color with these keys, like you did in the training. You will no longer receive feedback. Other blocks will be motion blocks, and you will have to respond based on the direction of the dot motion. Feel free to take a short break between blocks and come get me after you've finished all of the blocks. As always, please respond as quickly and accurately as you can.'





