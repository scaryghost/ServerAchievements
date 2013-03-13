Server Achievements
===============
## Version
1.1

## About
This package contains the infrastructure for creating custom achievements for Killing Floor.  By hooking into the game, 
it provides handlers for several in game events that can be utilized for custom achievements.  The mutator also provides 
an in-game menu to view achievement progress and saves achievement progress upon logging out or game end.

## Install
Copy the contents of the system and textures folders into their respective folder in the Killing Floor directory.  

## Configuration
The mutator can be configured by editting the ServerAchievements.ini file.  Below are descriptions for the properties:

    localHostSteamID64 - SteamID64 of the local host.  This is only needed for solo play or listen server hosts.
    achievementPacks   - Full classname ($packagename.$classname) of the achievement pack to use.  The property can 
                         be copied as many times as needed for multiple achievement packs
    useRemoteDatabase  - Check if the mutator should use a remote database for storing and retrieving achievement data
    tcpPort            - TCP port the remote database is listening on
    hostname           - Hostname of the remote database
    serverPassword     - Password to authenticate on the remote database
                         
Alternatively, the webadmin page and in-game mutator configuration menu can be used to change the mutator settings.  If 
configured from in game, the last 4 properties are only visible if the "View Advanced Options" box is checked

## Creating Custom Achievements
Please see the wiki for a guide on creating custom achievement packs based on the ServerAchievements engine.  
https://github.com/scaryghost/ServerAchievements/wiki/Creating-Custom-Achievements

## Source Code
https://github.com/scaryghost/ServerAchievements

## Acknowledgements
    Checkmark image   - http://www.freepik.com/free-vector/green-checkmark-and-red-minus_518315.htm
    Notification bgnd - http://xdotnano.wordpress.com/apparition2/
