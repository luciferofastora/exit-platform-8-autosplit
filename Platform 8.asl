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

    int    anomsVal     : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x20, 0xEE0,  0x98,  0x20, 0xFC0, 0x220,  0x38;
    bool   baseCleared  : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x20, 0xEE0,  0x98,  0x20, 0xFC0, 0x220,  0x28;
    bool   allAnomalies : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x20, 0xEE0,  0x98,  0x20, 0xFC0, 0x220,  0x29;
    bool   announcement : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x20, 0xFC0, 0x1E0,  0x78;

    int    levelVal     : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x30, 0x858,  0xC0, 0x298, 0x3B8;
    float  inGameTimer  : "Exit8-Win64-Shipping.exe", 0x0702F350,  0x30,  0x18, 0x240,  0xE8, 0x3C4;
    double posX         : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x30, 0x338, 0x660,  0x58, 0x260; 
    double posY         : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x30, 0x338, 0x660,  0x58, 0x268; 
    double posZ         : "Exit8-Win64-Shipping.exe", 0x074ACFC0,  0x30, 0x338, 0x660,  0x58, 0x270; 
    
}

startup 
{
    vars.resetBlockedOnce = false;
    vars.resetBlocked = false;
    vars.splitOnFirstCredits = false;
    vars.splitOnSecondCredits = false;
    
    settings.Add("overrideCategory", false, "Override Category Default Splits");
    settings.SetToolTip("overrideCategory", "Override the default splits for the selected category (Beat the Game / All Anomalies only)");
    settings.Add("firstCredits", false, "First Credits", "overrideCategory");
    settings.SetToolTip("firstCredits", "Split / Stop on reaching the first credits");
    settings.Add("secondCredits", false, "Second Credits", "overrideCategory");
    settings.SetToolTip("secondCredits", "Split / Stop on reaching the second credits"); 
}

init 
{
    //There is a delay between the game's timer starting and the actual start of the time per the official leaderboard rules. 
    //On my machine, that delay was measured to be 0.49s. If that should turn out to not be universal, people may have to make individual adjustments.
    //Additionally, the announcement adds another 13 seconds to the delay if it is active.
    vars.triggerOffset = current.announcement ? 13.49 : 0.49;
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
    
    vars.splitOnFirstCredits = settings["overrideCategory"] ? settings["firstCredits"] : timer.Run.CategoryName == "Beat The Game";
    vars.splitOnSecondCredits = settings["overrideCategory"] ? settings["secondCredits"] : timer.Run.CategoryName == "All Anomalies";
}

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
    return TimeSpan.FromSeconds((double) current.inGameTimer - vars.triggerOffset);
}

reset
{
    current.resetCondition = current.inGameTimer <= 0 && current.levelVal == 0 && current.anomsVal == 31;
    
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

onReset //On manual reset, clear reset blocking flags
{
    vars.resetBlockedOnce = false;
    vars.resetBlocked = false;
}
    

split 
{
    //Used for automatically splitting / stopping when reaching the respective credits
    double firstCreditThreshold = -147.0;
    
    return (vars.splitOnFirstCredits && current.levelVal == 9 && old.posY > firstCreditThreshold && current.posY <= firstCreditThreshold)
        || (vars.splitOnSecondCredits && old.allAnomalies && !current.allAnomalies);    
}


start 
{
    vars.triggerOffset = current.announcement ? 13.49 : 0.49; //Only update while timer is not running 
    //Start when 
    // - remaining anomalies = 31 
    // - inGameTimer crosses offset
   return current.inGameTimer >= vars.triggerOffset && old.inGameTimer < vars.triggerOffset && current.levelVal == 0 && current.anomsVal == 31;
}
