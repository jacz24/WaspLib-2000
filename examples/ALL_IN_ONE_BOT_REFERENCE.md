# All-In-One Bot - Quick Reference Card

A quick lookup guide for common operations and API methods.

## Table of Contents
1. [Initialization](#initialization)
2. [Activity Management](#activity-management)
3. [Configuration](#configuration)
4. [Progress Tracking](#progress-tracking)
5. [State Management](#state-management)
6. [Constants & Enums](#constants--enums)
7. [Common Patterns](#common-patterns)
8. [Debugging](#debugging)

---

## Initialization

### Basic Setup

```pascal
var AIOBot: TAIO;

AIOBot.Setup(3 * ONE_HOUR);  { 3 hour runtime }
AIOBot.Run();                  { Start main loop }
```

### With Activities

```pascal
AIOBot.Setup(5 * ONE_HOUR);

AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 99, 25);
AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 99, 25);

AIOBot.Run();
```

### Without GUI

```pascal
{ Skip form and run directly }
AIOBot.Setup(8 * ONE_HOUR);
AIOBot.AddActivity('Mining', ERSSkill.MINING, 99, 100);
AIOBot.Run();
```

---

## Activity Management

### Add Activity

```pascal
AIOBot.AddActivity(
  Name: String,           { Display name: 'Woodcutting' }
  Skill: ERSSkill,       { Which skill to track }
  TargetLevel: UInt32,   { Goal level: 99 }
  Weight: UInt32         { Selection weight: 25 }
);
```

### Enable/Disable Activity

```pascal
AIOBot.EnableActivity('Fishing', True);    { Enable }
AIOBot.EnableActivity('Mining', False);    { Disable }
```

### Check Current Activity

```pascal
var
  currentIdx: UInt32;
  currentActivity: TActivityConfig;

begin
  currentIdx := AIOBot.CurrentActivityIdx;
  currentActivity := AIOBot.Activities[currentIdx];
  WriteLn(currentActivity.Name);
end;
```

### Get Activity by Name

```pascal
function GetActivityByName(const Name: String): Integer;
var i: UInt32;
begin
  for i := 0 to High(AIOBot.Activities) do
    if AIOBot.Activities[i].Name = Name then
      Exit(i);
  Result := -1;  { Not found }
end;
```

### Modify Activity Weight

```pascal
var idx: Integer;
begin
  idx := GetActivityByName('Fishing');
  if idx >= 0 then
    AIOBot.Activities[idx].Weight := 50;  { Increase frequency }
end;
```

---

## Configuration

### Activity Switch Interval

```pascal
{ Time to spend on each activity before switching }
AIOBot.ActivitySwitchInterval := 10 * ONE_MINUTE;   { Default: 10 min }
AIOBot.ActivitySwitchInterval := 5 * ONE_MINUTE;    { Fast switching }
AIOBot.ActivitySwitchInterval := 20 * ONE_MINUTE;   { Long sessions }
```

### Antiban Breaks

```pascal
{ Chance to trigger break per bot cycle (0.0 to 1.0) }
AIOBot.AntibanBreakChance := 0.05;   { 5% chance }
AIOBot.AntibanBreakChance := 0.10;   { 10% chance (more breaks) }
AIOBot.AntibanBreakChance := 0.02;   { 2% chance (fewer breaks) }

{ Break duration range [min, max] in milliseconds }
AIOBot.BreakDuration := [1 * ONE_MINUTE, 5 * ONE_MINUTE];
AIOBot.BreakDuration := [2 * ONE_MINUTE, 10 * ONE_MINUTE];
AIOBot.BreakDuration := [500, 2000];  { Very short breaks }
```

### Break Schedule

```pascal
{ Specific times to take breaks (milliseconds from start) }
AIOBot.SetBreakSchedule([
  30 * ONE_MINUTE,    { 30 minutes in }
  60 * ONE_MINUTE,    { 60 minutes in }
  90 * ONE_MINUTE     { 90 minutes in }
]);
```

### Runtime Limit

```pascal
AIOBot.MaxRuntime := 5 * ONE_HOUR;      { 5 hours }
AIOBot.MaxRuntime := 8 * ONE_HOUR;      { 8 hours }
AIOBot.MaxRuntime := 0;                 { No limit (run until all done) }
```

---

## Progress Tracking

### Get Current Level

```pascal
var
  idx: UInt32;
  level: UInt32;
begin
  idx := 0;  { Woodcutting is first activity }
  level := AIOBot.SkillProgression[idx].CurrentLevel;
  WriteLn('Current Woodcutting Level: ' + ToStr(level));
end;
```

### Get Target Level

```pascal
var
  idx: UInt32;
  target: UInt32;
begin
  idx := 0;
  target := AIOBot.Activities[idx].TargetLevel;
  WriteLn('Target Woodcutting Level: ' + ToStr(target));
end;
```

### Check if Activity Finished

```pascal
var idx: UInt32;
begin
  idx := 0;
  if AIOBot.SkillProgression[idx].IsFinished then
    WriteLn('Woodcutting is complete!')
  else
    WriteLn('Woodcutting still in progress');
end;
```

### Get Action Count

```pascal
var
  idx: UInt32;
  actions: UInt64;
begin
  idx := 0;
  actions := AIOBot.SkillProgression[idx].Actions;
  WriteLn('Total Woodcutting Actions: ' + ToStr(actions));
end;
```

### Print All Progress

```pascal
AIOBot.PrintSkillProgress();  { Display summary }
```

### Get Total Actions

```pascal
var totalActions: UInt64;
begin
  totalActions := AIOBot.TotalActions;
  WriteLn('Total Actions Across All Skills: ' + ToStr(totalActions));
end;
```

---

## State Management

### Current State

```pascal
var state: EAIOState;
begin
  state := AIOBot.State;
  WriteLn('Current State: ' + ToStr(state));
end;
```

### All Possible States

```pascal
type
  EAIOState = enum(
    LOGIN,              { Not logged in }
    SELECT_ACTIVITY,    { Choosing next activity }
    EXECUTE_ACTIVITY,   { Running skill action }
    LEVEL_UP,           { Level up detected }
    BREAK_TIME,         { Taking antiban break }
    PROGRESS_CHECK,     { Checking progress }
    NO_ACTIVE_SKILLS,   { All skills finished }
    MAX_TIME_REACHED,   { Runtime limit hit }
    END_SCRIPT          { Ending bot }
  );
```

### Check if Bot Running

```pascal
if (AIOBot.State <> EAIOState.END_SCRIPT) and
   (AIOBot.State <> EAIOState.NO_ACTIVE_SKILLS) then
  WriteLn('Bot is still running')
else
  WriteLn('Bot has finished');
```

---

## Constants & Enums

### Time Constants (from WaspLib)

```pascal
one_ms        = 1;
one_second    = 1000;
ONE_MINUTE    = 60000;
ONE_HOUR      = 3600000;
one_day       = 86400000;
```

### Skill Enums

```pascal
ERSSkill.ATTACK
ERSSkill.DEFENCE
ERSSkill.STRENGTH
ERSSkill.HITPOINTS
ERSSkill.RANGED
ERSSkill.PRAYER
ERSSkill.MAGIC
ERSSkill.COOKING
ERSSkill.WOODCUTTING
ERSSkill.FLETCHING
ERSSkill.FISHING
ERSSkill.FIREMAKING
ERSSkill.CRAFTING
ERSSkill.SMITHING
ERSSkill.MINING
ERSSkill.HERBLORE
ERSSkill.AGILITY
ERSSkill.THIEVING
ERSSkill.SLAYER
ERSSkill.FARMING
ERSSkill.RUNECRAFT
ERSSkill.HUNTER
ERSSkill.CONSTRUCTION
```

### View All Skills

```pascal
{ To see all available skills, check the WaspLib documentation }
```

---

## Common Patterns

### Equal Weight Distribution

```pascal
var
  i: UInt32;
  weight: UInt32 := 25;
  activities: array of String := ['Woodcutting', 'Fishing', 'Mining', 'Cooking'];
begin
  for i := 0 to High(activities) do
    AIOBot.AddActivity(activities[i], GetSkillFromName(activities[i]), 99, weight);
end;
```

### Conditional Activity Setup

```pascal
var startLevel: UInt32;
begin
  startLevel := Stats.GetLevel(ERSSkill.WOODCUTTING);
  
  if startLevel < 50 then
    AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 50, 40);
  
  if startLevel >= 50 then
    AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 50, 40);
end;
```

### Progressive Level Targets

```pascal
function GetProgressiveTarget(BaseLevel, MaxLevel, ProgressionMultiplier: UInt32): UInt32;
begin
  Result := BaseLevel + ((MaxLevel - BaseLevel) * ProgressionMultiplier) div 100;
end;

var target: UInt32;
begin
  target := GetProgressiveTarget(10, 99, 50);  { Get 50% of way to 99 from 10 }
  AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, target, 25);
end;
```

### Pause Specific Activity

```pascal
procedure PauseActivity(const Name: String);
var idx: Integer;
begin
  idx := GetActivityByName(Name);
  if idx >= 0 then
    AIOBot.Activities[idx].Enabled := False;
end;

procedure ResumeActivity(const Name: String);
var idx: Integer;
begin
  idx := GetActivityByName(Name);
  if idx >= 0 then
    AIOBot.Activities[idx].Enabled := True;
end;
```

### Check All Skills Approaching Completion

```pascal
function AllSkillsNearCompletion(): Boolean;
var
  i: UInt32;
  pct: Single;
begin
  Result := True;
  
  for i := 0 to High(AIOBot.SkillProgression) do
  begin
    pct := (AIOBot.SkillProgression[i].CurrentLevel - AIOBot.SkillProgression[i].StartLevel) /
           (AIOBot.Activities[i].TargetLevel - AIOBot.SkillProgression[i].StartLevel);
    
    if pct < 0.9 then  { Less than 90% done }
      Result := False;
  end;
end;
```

---

## Debugging

### Print Activity Configuration

```pascal
procedure PrintActivityConfig(Index: UInt32);
var activity: TActivityConfig;
begin
  if Index >= Length(AIOBot.Activities) then Exit;
  
  activity := AIOBot.Activities[Index];
  WriteLn('Activity: ' + activity.Name);
  WriteLn('  Enabled: ' + BoolToStr(activity.Enabled));
  WriteLn('  Target Level: ' + ToStr(activity.TargetLevel));
  WriteLn('  Weight: ' + ToStr(activity.Weight));
end;
```

### Print All Activities

```pascal
procedure PrintAllActivities();
var i: UInt32;
begin
  WriteLn('=== ACTIVITIES ===');
  for i := 0 to High(AIOBot.Activities) do
    PrintActivityConfig(i);
  WriteLn('================');
end;
```

### Print Skill Progression Detail

```pascal
procedure PrintSkillDetail(Index: UInt32);
var skill: TSkillProgress;
begin
  if Index >= Length(AIOBot.SkillProgression) then Exit;
  
  skill := AIOBot.SkillProgression[Index];
  WriteLn('Skill: ' + ToStr(skill.Skill));
  WriteLn('  Current Level: ' + ToStr(skill.CurrentLevel));
  WriteLn('  Start Level: ' + ToStr(skill.StartLevel));
  WriteLn('  Actions: ' + ToStr(skill.Actions));
  WriteLn('  Finished: ' + BoolToStr(skill.IsFinished));
end;
```

### Runtime Statistics

```pascal
procedure PrintRuntimeStats();
var
  elapsed: UInt64;
  actionsPerSecond: Single;
begin
  elapsed := GetTickCount() - AIOBot.StartTime;
  actionsPerSecond := AIOBot.TotalActions / (elapsed / 1000);
  
  WriteLn('Elapsed Time: ' + ToStr(elapsed div 1000) + ' seconds');
  WriteLn('Total Actions: ' + ToStr(AIOBot.TotalActions));
  WriteLn('Actions/Second: ' + FloatToStr(actionsPerSecond, 2));
end;
```

### Check Activity Switch Countdown

```pascal
procedure PrintSwitchCountdown();
var
  elapsed, remaining: UInt64;
begin
  elapsed := GetTickCount() - AIOBot.LastActivitySwitch;
  remaining := AIOBot.ActivitySwitchInterval - elapsed;
  
  WriteLn('Time until activity switch: ' + ToStr(remaining div 1000) + ' seconds');
end;
```

### Get Enabled Activity Count

```pascal
function GetEnabledActivityCount(): UInt32;
var
  i: UInt32;
  count: UInt32 := 0;
begin
  for i := 0 to High(AIOBot.Activities) do
    if AIOBot.Activities[i].Enabled and not AIOBot.SkillProgression[i].IsFinished then
      Inc(count);
  Result := count;
end;
```

---

## Quick Troubleshooting

| Problem | Check | Fix |
|---------|-------|-----|
| No activities | `Length(AIOBot.Activities)` | Call `AddActivity()` before `Run()` |
| Staying on one skill | `ActivitySwitchInterval` | Reduce from 10 to 5 minutes |
| Levels not changing | `ExecuteActivity()` implementation | Ensure it performs valid actions |
| No breaks happening | `AntibanBreakChance` | Increase from 0.05 to 0.10 |
| Bot exits early | `MaxRuntime` and target levels | Check if targets are reachable |

---

## Useful Commands

```pascal
{ Print summary anytime }
AIOBot.PrintSkillProgress();

{ Check which activity is next }
WriteLn(AIOBot.Activities[AIOBot.CurrentActivityIdx].Name);

{ Get total runtime }
WriteLn(Logger.TimeRunning.ElapsedFmt(TIME_SHORT));

{ Force activity switch }
AIOBot.LastActivitySwitch := 0;
```

---

**TIP**: Keep this reference card open while developing your bot for quick lookups!
