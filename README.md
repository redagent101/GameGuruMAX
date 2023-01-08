# The GameGuru MAX Repository

This is not open source and remains the copyright of The Game Creators Ltd, see Wiki for more information on license matters. This repository contains the current source code to GameGuru MAX and is still under development as an Early Access project.

GameGuru MAX is a 3D game maker for simple first person games and is available to buy from Steam.

You will need the media files associated with the above product to use this repository.

This source code requires Visual Studio 2022 Community Edition. Ensure you add Visual C++ MFC for x86 and x64 to a clean install of VS2022.

Steos to compiling and running GameGuru MAX:

1. Buy GameGuru MAX from Steam and install. Download VS2022 and install.
2. In Windows 10, type ENV in the search box in the bottom left and hit ENTER
3. Click ENVIRONMENT VARIABLES and click NEW in the system variables section
4. Copy the contents of the MAX root (defaults to "D:\SteamLibrary\steamapps\common\GameGuru MAX" to a new BUILD folder of your choice
5. Enter "GG_MAX_BUILD_PATH" for the variable name and the path for the variable value, enter the BUILD folder of your choice
6. The BUILD folder might look like: "C:\DEV\BUILDS\GameGuru Wicked MAX Build Area\"
7. Now to go the CODE tab above, then click the CODE button and copy the Repository URL into your clipboard
8. Install GitHub Desktop and log in with a previously registered GitHub account
9. Use GitHub Desktop to CLONE a new repository, and provide the URL you previously copied
10. Ensure for the folder you specify is called GAMEGURUMAXREPO, located in a folder called DEV (i.e. D:|DEV\GAMEGURUMAXREPO)
11. Use back to GitHub and go to this repository, copy the URL to the clipboard: https://github.com/TheGameCreators/WickedRepo
12. As above, copy its URL then use GitHub Desktop to CLONE the repository and use the folder WICKEDREPO located in the DEV folder (i.e. D:|DEV\WICKEDREPO)
13. Ensure both GAMEGURUMAXREPO and WICKEDREPO folders are next to each other in the DEV folder and they are populated with files
14. Now download the "GameGuruMAX-MissingLIBs.zip" zip and extract it to copy in some missing LIB files to make compiling quicker and easier
15. For the above, the "GameGuru Core" folder should overwrite the one found at: "\DEV\GAMEGURUMAXREPO\GameGuru Core"
16. Now open the project "GameGuruWickedMAX.sln" using VS2022
17. Set the Solution Configuration from "Debug" to "Release"
18. Right click the "Wicked-MAX" on the left and select "Set as Startup Project"
19. Right click "Wicked-MAX" again and select REBUILD
20. When the compiling has finished, press the "Local Windows Debugger" button at the top to run GameGuru MAX via Visual Studio
