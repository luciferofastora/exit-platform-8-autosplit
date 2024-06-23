/*
    Autosplitter with In-Game Timer for Platform 8
    Author: LuciferOfAstora
    
    Currently tested: 
    -Platform 8 
        - Versions
            - 1.1.1.
    
    TODO:
     - test game / version compatibility
     - distinguish game save resets
     - detect credits 
     - customizable settings for categories 
*/

state("Exit8-Win64-Shipping") 
{
    int   levelVal    : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x20, 0xFC0, 0x220,  0x38;
    int   anomsVal    : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x20, 0xEE0,  0x98,  0x20, 0xFC0, 0x220,  0x38;
    bool announcement : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x20, 0xFC0, 0x1E0,  0x78;

    float inGameTimer : "Exit8-Win64-Shipping.exe", 0x0702F350,  0x30,  0x18, 0x240,  0xE8, 0x3C4;
    double posX       : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x30, 0x338, 0x660,  0x58, 0x260; 
    double posY       : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x30, 0x338, 0x660,  0x58, 0x268; 
    double posY       : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x30, 0x338, 0x660,  0x58, 0x270; 
}

/*
update
{
    //TODO: Distinguish death / All Anomalies completion / save deletion to restrict automatic reset to actual restarts
}
*/

/*
isLoading
{
    //Unused due to consensus about using IGT / Real Time
    //May be used for automatically pause during credits and black screen for more convenient splitting using "Game Time" as a workaround for counting only the valid run time.
}
*/


gameTime
{
    //Returns the current in-game timer for debugging puposes. Usually differs from Real Time by some offset.
    //Use in runs discouraged as game time isn't supported by leaderboard and resets on certain events. 
    return TimeSpan.FromSeconds((double) current.inGameTimer);
}



reset
{
    //TODO: Only reset on save deletion
    return current.inGameTimer < 0 && current.levelVal == 0 && current.anomsVal == 31;
}


/*
split 
{
    //Unused as splits don't currently make a lot of sense on a fairly random game
}
*/


start 
{
    //Start when 
    // - remaining anomalies = 31 
    // - inGameTimer crosses 0.49 
    //There is a delay between the game's timer starting and the actual start of the time per the official leaderboard rules. 
    //On my machine, that delay was measured to be 0.49s. If that should turn out to not be universal, people may have to make individual adjustments.
    //Additionally, the announcement adds another 13 seconds to the delay if it is active.
    
    double triggerOffset = current.announcement ? 13.49 : 0.49;
    return current.inGameTimer >= triggerOffset && old.inGameTimer < triggerOffset && current.levelVal == 0 && current.anomsVal == 31;
}
