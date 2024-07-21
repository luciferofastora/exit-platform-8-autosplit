/*
    Autosplitter with In-Game Timer for Platform 8
    Author: LuciferOfAstora
    
    Currently tested: 
    -Platform 8 
        - Versions
            - 1.1.1.
    
    TODO:
     - test game / version compatibility
     - distinguish game save reset from immediate death
     - detect credits 
     - customizable settings for categories 
*/

state("Exit8-Win64-Shipping") 
{
    //Current Save Data
    int    anomsVal     : "Exit8-Win64-Shipping.exe", 0x074C6670, 0xFC0, 0x220,  0x38;
    bool   baseCleared  : "Exit8-Win64-Shipping.exe", 0x074C6670, 0xFC0, 0x220,  0x28;
    bool   allAnomalies : "Exit8-Win64-Shipping.exe", 0x074C6670, 0xFC0, 0x220,  0x29;
    
    //Save Setings
    bool   announcement : "Exit8-Win64-Shipping.exe", 0x074C6670, 0xFC0, 0x1E0, 0x078;

    //Game state
    ulong  worldPointer : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078;
    double inGameTimer  : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078, 0x158, 0x2C0;

    //Player State
    int    levelVal     : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078, 0x158, 0x2A8, 0x000, 0x3E8;
    int    carIndex     : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078, 0x158, 0x2A8, 0x000, 0x3D0;
    
    //Player Pawn
    byte   movementMode : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078, 0x158, 0x2A8, 0x000, 0x308, 0x320, 0x1A4; 
    double posX         : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078, 0x158, 0x2A8, 0x000, 0x308, 0x328, 0x128; 
    double posY         : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078, 0x158, 0x2A8, 0x000, 0x308, 0x328, 0x130; 
    double posZ         : "Exit8-Win64-Shipping.exe", 0x074C6670, 0x9B8, 0x078, 0x158, 0x2A8, 0x000, 0x308, 0x328, 0x138;    
}

startup 
{
    vars.resetBlockedOnce = false;
    vars.resetBlocked = false;
    
    vars.splitOnFirstCredits = false;
    vars.splitOnSecondCredits = false;
    vars.timerOffset = 0.0;
    vars.delayStart = -1;
    
    settings.Add("overrideCategory", false, "Override Category Default Splits");
    settings.SetToolTip("overrideCategory", "Override the default splits for the selected category (Beat the Game / All Anomalies only)");
    settings.Add("firstCredits", false, "First Credits", "overrideCategory");
    settings.SetToolTip("firstCredits", "Split / Stop on reaching the first credits");
    settings.Add("secondCredits", false, "Second Credits", "overrideCategory");
    settings.SetToolTip("secondCredits", "Split / Stop on reaching the second credits"); 
}

onStart 
{
    //Note delay between world timer value and actual start of game
    vars.timerOffset = current.inGameTimer;
    
    //Lock in split settings on starting the timer
    vars.splitOnFirstCredits = settings["overrideCategory"] ? settings["firstCredits"] : timer.Run.CategoryName == "Beat The Game";
    vars.splitOnSecondCredits = settings["overrideCategory"] ? settings["secondCredits"] : timer.Run.CategoryName == "All Anomalies";
}

//GAME TIMER NOT LEGAL FOR LEADERBOARD - this section is only for debugging purposes
isLoading
{
    return true;
}

gameTime {
    return TimeSpan.FromSeconds(current.inGameTimer - vars.timerOffset);
}

update
{
    //Distinguish between a reset from All Anomaly completion, from death on first anomaly and from actual save reset
    //All Anomalies: Save (and flag) is reset when reaching credits -> Block reset once
    if (old.allAnomalies && !current.allAnomalies) 
    {
        vars.resetBlockedOnce = true;
    }        
    //TODO: Detect death
    
    
    //The player position is reset to starting position right before the game starts, but the timer only counts from the first non-black frame. 
    //This delay bridges those two frames
    if ( vars.delayStart > -1 ) 
    {
        vars.delayStart--;
    }
    if ( old.posY == 0 && current.posY >= 120.49 && current.posY <= 120.51)
    {
        vars.delayStart = 2;
    }   
}

reset
{
    //World and save data reset
    current.resetCondition = current.worldPointer == 0 && current.levelVal == 0 && current.anomsVal == 31;
    
    if (vars.resetBlocked)
    {
        return false;
    }
    
    if (vars.resetBlockedOnce)
    {
        if (old.resetCondition && !current.resetCondition) //Once the reset condition is no longer given, clear the Blocked Once flag
        {
            vars.resetBlockedOnce = false;
        }
        return false;
    } 
    else return current.resetCondition;
}

onReset //On manual reset, clear flags
{
    vars.resetBlockedOnce = false;
    vars.resetBlocked = false;
    vars.timerOffset = 0.0;
    
}
    

split 
{
    //Used for automatically splitting / stopping when reaching the respective credits
    double firstCreditThreshold = 86.3;
    
    return (vars.splitOnFirstCredits && current.levelVal == 9 && old.posZ > firstCreditThreshold && current.posZ <= firstCreditThreshold)
        || (vars.splitOnSecondCredits && old.allAnomalies && !current.allAnomalies);    
}


start 
{
    //Start when 
    // - all save values are default
    // - position in seat is initialised
    // - start delay has expired
    return 
        vars.delayStart == 0
        && current.anomsVal == 31
        && current.baseCleared == false;
    ;
}
