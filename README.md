# RetroAchievements Library Validator

This project aims to make the process of checking the validity of your ROMs for RetroAchievements a breeze. Just download the script or clone the repository, configure your variables, and get a report of which ROMs are valid for earning achievements. If you have any questions, please feel free to message me on Discord directly or @ me in the RA Discord.

## Prerequisites

Before using the script, ensure you have the following prerequisites set up:

1. **RAHasher**: 
   - Download RAHasher from [RetroAchievement's GitHub](https://github.com/RetroAchievements/RALibretro/releases).
   - Make note of the path to `RAHasher.exe`, as this will be needed in the script configuration.

2. **RetroAchievements Account**:
   - You need a RetroAchievements account and API key.
   - You can find or generate your API key by logging into [RetroAchievements](https://retroachievements.org) and navigating to the control panel: [https://retroachievements.org/controlpanel.php](https://retroachievements.org/controlpanel.php).

3. **PowerShell**:
   - Ensure you are using PowerShell to run this script.

## Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Siallus/RetroAchievementsLibraryValidator
   ```

2. **Configure Script Variables**:

   Open the script and set the following variables according to your system configuration:

   - `$ROM_BASE_PATH`: Path to the root folder containing your ROMs. Each system should have its own subfolder within this path.
   - `$RAHASHER_PATH`: Path to the `RAHasher.exe` program.
   - `$HASH_OUTPUT_PATH`: Path to the folder where the hash report will be exported.
   - `$RA_USERNAME`: Your RetroAchievements username.
   - `$RA_API_KEY`: Your RetroAchievements API key.

   Example:
   ```powershell
   $ROM_BASE_PATH = 'C:\Games\ROMs'
   $RAHASHER_PATH = 'C:\Tools\RAHasher'
   $HASH_OUTPUT_PATH = 'C:\Games\HashReports'
   $RA_USERNAME = 'your_username'
   $RA_API_KEY = 'your_api_key'
   ```

3. **Map System Folders**:

   The `$SYSTEM_TO_FOLDER_MAP` hash table should match RetroAchievements system names to their respective subfolders under `$ROM_BASE_PATH`. If a system is not available, leave its value as an empty string. Here’s an example for a few systems:

   ```powershell
   $SYSTEM_TO_FOLDER_MAP = @{
       'NES/Famicom' = 'NES'
       'SNES/Super Famicom' = 'SNES'
       'Game Boy' = 'GameBoy'
   }
   ```
   
## Running the Script

Once everything is set up, you can run the script to hash your ROMs and generate a report.

1. Open PowerShell and navigate to the directory where the script is located.
2. Run the script:
   ```powershell
   .\Get-RomHashes.ps1
   ```

The script will attempt to match each ROM file in your specified system folders with the RetroAchievements database. It will generate a CSV file at the specified `$HASH_OUTPUT_PATH`, detailing the results of each match, including game titles and achievement counts.

## CSV Output

The resulting CSV report contains the following columns:

- `MatchFound`: Indicates whether a matching ROM was found in the RetroAchievements database.
- `System`: The system name (e.g., NES, SNES).
- `RomName`: The filename of the ROM.
- `Hash`: The calculated hash of the ROM file.
- `Path`: The folder path where the ROM is located.
- `RATitle`: The game title according to RetroAchievements.
- `RAID`: The RetroAchievements ID of the game.
- `CheevoCount`: The number of achievements for the game.

## Notes

- PowerShell now warns the user of a script execution risk when running Invoke-WebRequest. The script only makes calls out to 2 RetroAchievements API endpoints, but one of these endpoints can be called numerous times depending on how many systems you have ROMs for.
- Ensure that your system folder names in `$SYSTEM_TO_FOLDER_MAP` match exactly with the corresponding subfolders in `$ROM_BASE_PATH`.
- The script uses RAHasher to generate hashes for ROMs. Ensure that RAHasher is correctly installed and accessible from the path specified in `$RAHASHER_PATH`.

## Disclaimer

This script is a work in progress but is expected to function well into the future given the stability and longevity of the tools it utilizes, such as RAHasher and the RetroAchievements API.

## Future Enhancements

- Add support for renaming ROMs to match the RetroAchievements standard.
- Add support for checking individual ROMs.
- Add additional error checking and handling.
- General cleanup.
