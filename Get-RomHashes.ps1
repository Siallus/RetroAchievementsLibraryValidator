# Path to ROM files
# ROMs should be contained within folders of each system
$ROM_BASE_PATH = ''
# Path to the RAHasher.exe program
$RAHASHER_PATH = ''
# Path to export hash report
$HASH_OUTPUT_PATH = ''

# Retroachievements username and web API key
# API key found/generated here: https://retroachievements.org/controlpanel.php
$RA_USERNAME = ''
$RA_API_KEY = ''

# Rename rom files to match the Retroachievements database for all matches found
# UNUSED
$RENAME_ROMS_TO_RA_STANDARD = $false

# Match the below systems to the system folders within $ROM_BASE_PATH
$SYSTEM_TO_FOLDER_MAP = @{
    '32X'                         = ''
    '3DO Interactive Multiplayer' = ''
    'Amstrad CPC'                 = ''
    'Apple II'                    = ''
    'Arcade'                      = ''
    'Arcadia 2001'                = ''
    'Arduboy'                     = ''
    'Atari 2600'                  = ''
    'Atari 7800'                  = ''
    'Atari Jaguar'                = ''
    'Atari Jaguar CD'             = ''
    'Atari Lynx'                  = ''
    'ColecoVision'                = ''
    'Dreamcast'                   = ''
    'Elektor TV Games Computer'   = ''
    'Fairchild Channel F'         = ''
    'Game Boy'                    = ''
    'Game Boy Advance'            = ''
    'Game Boy Color'              = ''
    'Game Gear'                   = ''
    'GameCube'                    = ''
    'Genesis/Mega Drive'          = ''
    'Intellivision'               = ''
    'Interton VC 4000'            = ''
    'Magnavox Odyssey 2'          = ''
    'Master System'               = ''
    'Mega Duck'                   = ''
    'MSX'                         = ''
    'Neo Geo CD'                  = ''
    'Neo Geo Pocket'              = ''
    'NES/Famicom'                 = ''
    'Nintendo 64'                 = ''
    'Nintendo DS'                 = ''
    'Nintendo DSi'                = ''
    'PC Engine CD/TurboGrafx-CD'  = ''
    'PC Engine/TurboGrafx-16'     = ''
    'PC-8000/8800'                = ''
    'PC-FX'                       = ''
    'PlayStation'                 = ''
    'PlayStation 2'               = ''
    'PlayStation Portable'        = ''
    'Pokemon Mini'                = ''
    'Saturn'                      = ''
    'Sega CD'                     = ''
    'SG-1000'                     = ''
    'SNES/Super Famicom'          = ''
    'Standalone'                  = ''
    'Uzebox'                      = ''
    'Vectrex'                     = ''
    'Virtual Boy'                 = ''
    'WASM-4'                      = ''
    'Watara Supervision'          = ''
    'WonderSwan'                  = ''
}

function Get-RASystemsList {
    $ConsolesBasePath = 'https://retroachievements.org/API/API_GetConsoleIDs.php'
    $ConsolesArgs = "z=$RA_USERNAME&y=$RA_API_KEY&a=1&g=1"
    $ConsolesFullPath = $ConsolesBasePath + "?" + $ConsolesArgs
    
    $Consoles = (Invoke-WebRequest $ConsolesFullPath).Content
    
    return ($Consoles | ConvertFrom-Json) | Select-Object ID, Name
}

function Get-RAGamesList ([string]$SystemID) {
    $GamesBasePath =  'https://retroachievements.org/API/API_GetGameList.php'
    $GamesArgs = "z=$RA_USERNAME&y=$RA_API_KEY&i=$SystemID&h=1"
    $GamesFullPath = $GamesBasePath + "?" + $GamesArgs

    $Games = (Invoke-WebRequest $GamesFullPath).Content
    
    return ($Games | ConvertFrom-Json) | Select-Object ID, Title, ConsoleID, ConsoleName, NumAchievements, Hashes
}

$Systems = [System.Collections.Generic.List[Object]]::New()
$SYSTEM_TO_FOLDER_MAP.Keys | ForEach-Object {
    If ($SYSTEM_TO_FOLDER_MAP.$_) {
        $Systems.Add([PSCustomObject]@{
            System = $_
            SystemFolder = $SYSTEM_TO_FOLDER_MAP.$_
        })
    }
}

If ($Systems.Count -lt 1) {
    Write-Host "No system paths mapped. Please update `$SYSTEM_TO_FOLDER_MAP and rerun the script." -ForegroundColor Red
    Exit
}

$PathFound = $False
$SystemsToRemove = @()

Foreach ($System in $Systems) {
    If (-not(Test-Path -Path "$ROM_BASE_PATH\$($System.SystemFolder)")) {
        Write-Host "Invalid path: $ROM_BASE_PATH\$($System.SystemFolder). Skipping path for hash matching." -ForegroundColor Red
        $SystemsToRemove += $System 
        Continue
    }
    $PathFound = $True
}

$SystemsToRemove | ForEach-Object { $Systems.Remove($_) } | Out-Null

If (-not($PathFound)) {
    Write-Host "None of the provided system paths are valid. Please update the system values in `$SYSTEM_TO_FOLDER_MAP to match the subfolders found in $ROM_BASE_PATH and rerun the script." -ForegroundColor Red
    Exit
}

$RASystems = Get-RASystemsList

$HashOutputObject = [System.Collections.Generic.List[Object]]::New()

Foreach ($System in $Systems) {
    $SystemID = $RASystems | Where-Object { $_.Name -eq $System.System } | Select-Object -ExpandProperty ID
    $RAGames = Get-RAGamesList -SystemID $SystemID

    $RomFiles = Get-ChildItem -Path "$ROM_BASE_PATH\$($System.SystemFolder)" -File
    Foreach ($RomFile in $RomFiles) {
        $FileHash = cmd /c "$RAHASHER_PATH\RAHasher.exe" $SystemID $RomFile.FullName
        If ($FileHash.Length -ne 32) {
            Write-Host "Unable to parse $($RomFile.Name)" -ForegroundColor Red
            $HashOutputObject.add([PSCustomObject]@{
                MatchFound = $false
                System = $System.System
                RomName = $RomFile.Name
                Hash = $FileHash
                Path = "$ROM_BASE_PATH\$($System.SystemFolder)"
                RATitle = ''
                RAID = ''
                CheevoCount = ''
            })
            Continue
        }

        $RomMatch = $RAGames | Where-Object { $_.hashes -match $FileHash }
        If (($RomMatch | Measure-Object).Count -lt 1) {
            #Write-Host "Bad file hash for $($RomFile.Name)" -ForegroundColor Red
            $HashOutputObject.add([PSCustomObject]@{
                MatchFound = $false
                System = $System.System
                RomName = $RomFile.Name
                Hash = $FileHash
                Path = "$ROM_BASE_PATH\$($System.SystemFolder)"
                RATitle = ''
                RAID = ''
                CheevoCount = ''
            })
            
            Continue
        }

        $HashOutputObject.add([PSCustomObject]@{
            MatchFound = $true
            System = $System.System
            RomName = $RomFile.Name
            Hash = $FileHash
            Path = "$ROM_BASE_PATH\$($System.SystemFolder)"
            RATitle = $RomMatch.Title
            RAID = $RomMatch.ID
            CheevoCount = $RomMatch.NumAchievements
        })
    }
}

$HashOutputObject | Export-Csv "$HASH_OUTPUT_PATH\RA_HashMapReport.csv" -NoTypeInformation
