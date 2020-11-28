# Factorio-Biter-Santa
Adds a flying biter santa and sleigh that can be called in by command, will land and then can be dismissed by command to fly away.

Landing:
![Laninding](https://thumbs.gfycat.com/UnimportantAlarmingHarborporpoise.webp)
Vertical Takeoff option:
![Vertical Taekoff](https://thumbs.gfycat.com/BlindAntiqueApe.webp)

Features
-------

- A flying Santa sleigh being pulled by biters. Made from ingame assets so fits in base game graphically.
- Santa will take 60 tiles to land and take off using a horizontal (runway) approach. It will detroy any ground based things in this path.
- Options for Santa to use Vertical Take Off or a horizontal runway take off to depart.
- Configurable start, landing and disappearing position through the clouds. Also updatable via commands.
- Configurable santa status messages.
- Santa is indestructible and cannot be interacted with in any way other than the commands.
- Santa can optionally have a configurable inventory of presents and can then be clicked on to take the presents.

Commands
-------

- call-santa: Call santa to fly in and land
- dismiss-santa: Send santa to take off and fly away
- delete-santa: Removes santa from the map instantly
- set-santa-landing-position: Set a new santa landing spot, overriding the mod setting. Takes arguments of x and y coordinates with a space between them, or blank to undo the mod set position and return to the mod setting. i.e. /set-santa-landing-position 14.5 -64
- offset-santa-landing-position: Update santa's landing position by an offset to the current position (command or mod settings set). Takes arguments of x and y offset values with a space between them. i.e. /offset-santa-landing-position 10 0


Example Ingame
----------
Calling Santa to the wrong spot on the map can be a little problematic.
Arriving: https://www.twitch.tv/jd_play5/clip/ShyEnchantingBaboonPunchTrees
Explosive Departure: https://www.twitch.tv/jd_play5/clip/FaithfulPiercingStarLeeroyJenkins


Upgrading
---------
Maps using version 17.1.2 or below must fully dismiss Santa before upgrading. Version 17.1.3 will not affect any older Santa elements in the map. Given the mods usage pattern this shouldn't be an issue.


Notes
-----

- Best used during the day as no lights are included on santa. This is as I can't make lights on santa affect only it and not the buildings behind it due to Factorios 2D view of height.
- All mod settings are cached for santa when called in to avoid weird situations. So set everything up first.