# Technical Info

This is documentation for the implementation of the splitters found in this repository. For information on use and installation, please refer to the README.

## How the splitter works

The way it works is pretty simple. The splitter grabs various values from the IronBramble.exe process memory to determine the game state. When certain conditions are met (such as room transitions or menu status), it goes to the next split. Upon startup, it defines the splits to be used in the run. The user can configure what splits are used in the ScriptableAutoSplitter settings within Livesplit.

For posterity, the split tuples are defined with the format (previous_room, current_room, split_name). In the split section, it checks if the previous (old) and room and the current room match any of these tuples. If so, it goes to the next split. The split_name is purely for display within the autosplitter settings and does not impact execution.

ASL maintains a few objects and references that we can use, but one of the more important ones are the "current" and "old" references. These refer to the state of the memory in the current and previous scan respectively. This is useful for change detection, such as tracking room transitions and menu states.

The program execution is as follows:
- Upon startup, the script defines the process name ("IronBramble") and defines the memory addresses it needs to track the gamestate. It then creates a string list that tracks transitions that have triggered a split. Finally, it formats the split definitions into the formal used internally by ASL.
- When the timer is inactive, the "start" block loops until the start condition is triggered. The cutscene room before the first room has a room id of 203, while the starting room has an id of 279. When that transition occurs, the timer starts. It also resets the used_transitions list. Without this, the program would skip transition triggers that were hit on the previous run.
- The split section tracks two things
- 1. It checks if the old room is different than the current room. If it is, a transition occured. If this transition should trigger a split, and it has not been triggered yet, then it returns "true" to tell Livesplit to go to the next split. It also saves that transition in the used_transitions list so it does not get triggered if you go through that transition again.
- 2. If the menu memory values change (more on those later), then it checks if they have been set to 1 and if you are in the final boss room (258). If so, then the game is over and it triggers the next split. Since this is always the final split, this ends the timer.
- Finally, the "reset" block is an optional block that stops the timer when you go to the home menu, saving having to manually reset. This can be toggled in the settings. It checks if you are in room 206 (the home menu), and if you are, then ASL automatically resets livesplit. Worth noting that this does not reset a completed timer. With the current rules, you are not allowed to go to the main menu during a run, so that shouldn't be an issue either.

## The memory addresses
The memory addresses used by this splitter were found using a software called "Cheat Engine", which allows you to view and modify the memory of any running process. The addresses used are relative to the exe, so they do not change upon relaunch. The "room" integer is the simplest. It's the in-game room ID. Their use is explained in the program execution section above.

The last two addresses (menu1 and menu2) are a bit confusing, as I'm not 100% sure what they even do. After a fair bit of investigation, I found that these addresses respond to two main things:
- When you interact with a checkpoint, they both get set to 2
- When the buttons show up after completing the demo, they both get set to 1

What are they measuring/controlling? No idea. My working theory is that they control the status of the buttons, but I have no proof of this. As for the control logic, when the player is in room 258 (the Lark fight) and both of those values get set to 1, then the splitter goes to the next split. Since there is only one split set, this ends the timer.

This has been tested on Windows 11 and Linux and seems to work correctly. Not sure about other platforms, but those can be addressed as they come up.
