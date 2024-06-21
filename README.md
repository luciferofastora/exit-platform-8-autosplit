# Autosplitter for The Exit 8 and Platform 8
This repository contains my current development state of a LiveSplit Autosplitter Script for Platform 8 (and at some point hopefully The Exit 8 as well).
Additionally, it provides a default LiveSplit Layout and Split files for Platform 8 which I use for my own LiveSplit. 
These are provided as-is without any warranty.

## Supported Games and Versions
This timer has so far been tested for:
- Platform 8 
  - Beat the Game and All Anomalies only
  - v 1.1.1

Other versions (including those of Exit 8) may work as well, but have not been tried so far. 
If you have test results to contribute here, please let me know through a [GitHub Issue](https://github.com/luciferofastora/exit-platform-8-autosplit/issues) or by contacting me through the [official Exit 8 / Platform 8 Speedrunning Discord](https://discord.com/invite/WfAv8Vad33).
I also haven't tested restarting the game mid-run (as may be required for Platform 8 - All Achievements) for technical reasons. I appreciate feedback on that as well.

## Features
### Platform 8
Automatic reset and (re-)start when the player is returned to the game area after
  - Deleting the save
  - Dying *without beating any anomalies before*
  - Completing All Anomalies

Deleting the save after such a death or a completion will count as an additional "attempt" in the split files. 
I haven't found a way to circumvent this so far. 

**Notes:** 

The timer currently starts earlier than the actual time specified by the official leaderboard rules, which starts the moment the blackscreen disappears. 
If you wish to have an accurate and compliant time, you will need to offset the start time in your split settings accordingly (-0.49s on my machine).
There is also no auto-stop on reaching the credits, and it's currently not clear if that will be possible for Real Time measurements. 
You will have to stop the timer manually for now. More on this in [Usage](#usage)

### The Exit 8
The executable for Platform 8 is largely built on the base of The Exit 8. It may well be the case that the above features work for that game as well. 
However, this has not been tested yet (see the [Supported Games and Versions](#supported-games-and-versions) above).

## Usage
### Short version
- Select my `.asl` script for the Script Path of an "Scriptable Auto Splitter" component
- Set the timer to start at -0.49 in your splits
- Use Real Time Comparison (Game Time is wrong currently)
- Manually split (stop) on reaching the end for your category. 

### Long version 
#### Setting up Autosplitter
1. Save the `.asl` and optionally `.lsl` and `.lss` file(s) to some directory where you'll find them.
2. (Optional) In LiveSplit, right-click the timer and select Open Layout > From File, then select my premade `.lsl` file.
2. Right-click the timer and select Edit Layout.
3. If you're using or editing your own layout, add a "Scriptable Auto Splitter" component to it: Click the plus button, then select Control > Scriptable Auto Splitter.
4. Double-Click the "Scriptable Auto Splitter" component to open the settings, then use Browse to select the `.asl` file. Your auto-splitter should immediately be loaded and active. 
5. (Optional) If you wish to disable the Auto-Start or -Reset, untick the respective checkboxes below the Script Path selector.

#### Setting up the Timer
The timer currently starts earlier than the actual start time specified by the official speedrun.com rules (which counts from the moment the black screen fades). 
If you wish to have an accurate starting time compliant with those rules, either 
6. Load my premade split file for your game and category with Open Splits > From File to select the relevant `.lss` file.
7. Alternatively, edit your own splits and set the "Start timer at:" setting to -0.49.

(Optional) To display the game and category in the title of your timer and load the relevant world record from speedrun.com:
8. Set the game and category in the title of your timer. Entering / selecting the game should automatically load the official categories to select from the dropdown.
9. Set additional variables in the "Additional Info" tab. 
Note: If you have set the layout's World Record component to include variables, it will be very picky with the exact combination of variables. I'm not aware of a more lenient option for any of them so far.

## Contact and Contributions
If you have feedback or problems, feel free to open an issue here. That includes reports on the splitter working or not working for a given version. 
If you would like to contribute to the project, you can also create a fork and open a pull request with your changes.

You can also reach me through the [official Exit 8 / Platform 8 Speedrunning Discord](https://discord.com/invite/WfAv8Vad33) if I'm not responding here or for questions that don't warrant an issue. 
I usually check that more often than I may check this repository. 
