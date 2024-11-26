# sber_hackaton_fpga
======

## What kind of event?
FRKT MIPT and Sber organized "Sber Hack&Learn Day" 8-9.11.24. The task of our team "Bit_Banders" was to create own game using the functionality of the Nexus 7 Artix-7 FPGA.

## Description of the game
The essence of the game is that by controlling a fireball that is released by a dragon, which is also controlled by users, they hit an alien, who is an npc character walking from one side to the other and jumping.

## Board functionality
Below is the functionality of the board, which was used in the implementation of the game and where it is used:
*accelerometer         - fireball control
*7-segment indicators  - shows x and y coordinates relative to the surface
*buttons               - dragon control
*switches              - fireball release (character control change)
*VGA                   - image output to the screen

## Realization
The basis of the implementation was as follows:
*The images were implemented simply by downloading .png images from the Internet and using a script to output them.
*The transparent background of the pictures was made by addressing the background pixels instead of the background pixels of the characters
*The mechanics of the jump were implemented using a finite state machine
*The characters were controlled by changing their coordinates

## Authors
The "Bit_Banders" team:
1. [Bunakov Egor](https://t.me/Egor_Bunakov)
2. [Kokonin Egor](https://t.me/Nojey)
3. [Vetochkin Igor](https://t.me/Igor_Veto4kin)
