# All-In-One Bot Framework

A comprehensive, production-ready bot framework for WaspLib that enables multi-skill training with dynamic activity switching. This framework allows players to level multiple skills simultaneously with a single bot instance.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Core Features](#core-features)
4. [Data Structures](#data-structures)
5. [Implementation Guide](#implementation-guide)
6. [Usage Examples](#usage-examples)
7. [Extending the Framework](#extending-the-framework)
8. [State Machine](#state-machine)
9. [Progress Tracking](#progress-tracking)
10. [Configuration Management](#configuration-management)

---

## Overview

The All-In-One Bot is a flexible framework designed to:

- **Support Multiple Activities**: Dynamically switch between different skills/activities
- **Independent Progress Tracking**: Track level progression for each skill separately
- **Weighted Activity Selection**: Use configurable weights to balance time spent on each activity
- **Antiban Integration**: Seamless antiban system integration across all activities
- **Persistent Configuration**: Save and load bot settings between sessions
- **Real-time Progress Reporting**: Monitor all skill progression in real-time

---

## Architecture

### High-Level Design

```
┌─────────────────────────────────────────────┐
│         ALL-IN-ONE BOT CONTROLLER           │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │      State Machine (GetState)       │   │
│  │  - LOGIN                            │   │
│  │  - SELECT_ACTIVITY                  │   │
│  │  - EXECUTE_ACTIVITY                 │   │
│  │  - LEVEL_UP                         │   │
│  │  - BREAK_TIME                       │   │
│  │  - END_SCRIPT                       │   │
│  └─────────────────────────────────────┘   │
│           │                                 │
│           ├─ Activity Config Array          │
│           ├─ Skill Progress Tracker         │
│           ├─ Runtime Tracking               │
│           └─ Antiban Settings               │
└─────────────────────────────────────────────┘
          │
          ├─ Activity Selector (Weighted)
          ├─ Skill Monitoring System
          ├─ Progress Reporter
          └─ Configuration Manager
```

### Component Interactions

1. **Main Bot Record (TAIO)**: Central controller managing all operations
2. **Activity Configuration (TActivityConfig)**: Stores settings per activity
3. **Skill Progression (TSkillProgress)**: Tracks individual skill advancement
4. **State Machine**: Determines bot behavior based on current conditions
5. **Progress Reporter**: Displays real-time statistics

---

## Core Features

### 1. Multi-Skill Support

The framework supports unlimited activities/skills:

```pascal
AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 60, 25);
AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 60, 25);
AIOBot.AddActivity('Mining', ERSSkill.MINING, 60, 25);
AIOBot.AddActivity('Cooking', ERSSkill.COOKING, 60, 25);
```

### 2. Dynamic Skill Switching

Activities are switched based on:
- Configurable time intervals (default 10 minutes)
- Weighted random selection (higher weight = more frequent)
- Completion status (finished skills are excluded)

### 3. Independent Progress Tracking

Each skill maintains:
- Current level
- Starting level
- Total XP gained (extendable)
- Action count
- Completion status

### 4. Weighted Activity Selection

Balance different activities using weight values:

```pascal
// Equal distribution
AddActivity('Skill1', ERSSkill.SKILL_1, 99, 25);
AddActivity('Skill2', ERSSkill.SKILL_2, 99, 25);

// Prioritize Skill1
AddActivity('Skill1', ERSSkill.SKILL_1, 99, 40);
AddActivity('Skill2', ERSSkill.SKILL_2, 99, 20);
```

### 5. Comprehensive Antiban Integration

- Automatic breaks triggered probabilistically
- Configurable break duration
- Break timing considerations
- Full WaspLib antiban system support

---

## Data Structures

### TActivityConfig

```pascal
type
  TActivityConfig = record
    Name: String;                   // Display name (e.g., 'Woodcutting')
    Enabled: Boolean;              // Can toggle on/off from GUI
    TargetLevel: UInt32;           // Level to stop at
    MaxActionsPerCycle: UInt32;    // Actions before switching (optional)
    Weight: Single;                // Selection probability weight
  end;
```

### TSkillProgress

```pascal
type
  TSkillProgress = record
    Skill: ERSSkill;               // Which skill enum (WOODCUTTING, etc.)
    CurrentLevel: UInt32;          // Live level tracking
    StartLevel: UInt32;            // Initial level when bot started
    TotalXP: UInt64;               // Cumulative XP gained
    Actions: UInt64;               // Total action count
    IsFinished: Boolean;           // Target level reached
  end;
```

### TAIO (Main Bot Record)

```pascal
type
  TAIO = record
    State: EAIOState;              // Current state
    Activities: array of TActivityConfig;        // All activities
    SkillProgression: array of TSkillProgress;   // Progress tracking
    CurrentActivityIdx: UInt32;    // Currently executing activity
    
    { Runtime metrics }
    TotalActions: UInt64;          // Combined action count
    MaxRuntime: UInt64;            // Milliseconds before auto-stop
    StartTime: UInt64;             // Timestamp when bot started
    ActivitySwitchInterval: UInt64;// Delay between activity changes
    
    { Antiban configuration }
    AntibanBreakChance: Single;    // 0.0 to 1.0 probability
    BreakDuration: TIntArray;      // Min/max break duration
  end;
```

---

## Implementation Guide

### Step 1: Initialize the Bot

```pascal
var
  AIOBot: TAIO;

begin
  AIOBot.Setup(3 * ONE_HOUR);  // 3-hour runtime
end;
```

### Step 2: Add Activities

```pascal
{ AddActivity(Name, Skill Enum, Target Level, Weight) }
AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 60, 25);
AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 60, 25);
AIOBot.AddActivity('Mining', ERSSkill.MINING, 60, 20);
```

### Step 3: Configure Runtime Parameters

```pascal
{ Adjust activity switch timing }
AIOBot.ActivitySwitchInterval := 15 * ONE_MINUTE;

{ Configure antiban breaks }
AIOBot.AntibanBreakChance := 0.08;  // 8% chance per cycle
AIOBot.BreakDuration := [2 * ONE_MINUTE, 8 * ONE_MINUTE];

{ Or use preset break schedule }
AIOBot.SetBreakSchedule([1800000, 3600000, 5400000]);  // Breaks at 30, 60, 90 minutes
```

### Step 4: Implement Activity Execution

In the `ExecuteActivity()` procedure, add your activity logic:

```pascal
procedure TAIO.ExecuteActivity();
var
  actIdx: UInt32;
  activity: TActivityConfig;
begin
  actIdx := Self.CurrentActivityIdx;
  activity := Self.Activities[actIdx];

  case activity.Name of
    'Woodcutting': DoWoodcutting();
    'Fishing': DoFishing();
    'Mining': DoMining();
    'Cooking': DoCooking();
  end;

  Self.UpdateSkillProgress(actIdx);
  Antiban.DoAntiban();
end;
```

### Step 5: Run the Bot

```pascal
begin
  AIOBot.Run();  // Main loop
end;
```

---

## Usage Examples

### Example 1: Balanced Multi-Skill Training

```pascal
var AIOBot: TAIO;

begin
  AIOBot.Setup(8 * ONE_HOUR);
  
  AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 99, 25);
  AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 99, 25);
  AIOBot.AddActivity('Mining', ERSSkill.MINING, 99, 25);
  AIOBot.AddActivity('Cooking', ERSSkill.COOKING, 99, 25);
  
  AIOBot.ActivitySwitchInterval := 10 * ONE_MINUTE;
  AIOBot.AntibanBreakChance := 0.06;
  
  AIOBot.Run();
end.
```

### Example 2: Prioritized Skill Training

```pascal
var AIOBot: TAIO;

begin
  AIOBot.Setup(5 * ONE_HOUR);
  
  { Spend 50% time on primary skill }
  AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 85, 50);
  
  { Spend 25% on secondary skills }
  AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 70, 25);
  AIOBot.AddActivity('Mining', ERSSkill.MINING, 75, 25);
  
  AIOBot.Run();
end.
```

### Example 3: Conditional Activity Enabling

```pascal
var AIOBot: TAIO;

begin
  AIOBot.Setup(10 * ONE_HOUR);
  
  AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 99, 25);
  AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 99, 25);
  AIOBot.AddActivity('Mining', ERSSkill.MINING, 99, 25);
  AIOBot.AddActivity('Cooking', ERSSkill.COOKING, 99, 25);
  
  { Disable activities based on conditions }
  if Stats.GetLevel(ERSSkill.FISHING) < 50 then
    AIOBot.EnableActivity('Fishing', False);
  
  AIOBot.Run();
end.
```

---

## Extending the Framework

### Adding Custom Activity Execution

Implement skill-specific logic in `ExecuteActivity()`:

```pascal
procedure DoWoodcutting();
begin
  { 1. Find nearest tree }
  { 2. Click tree }
  { 3. Wait for animation }
  { 4. Handle full inventory }
end;

procedure DoFishing();
begin
  { 1. Navigate to fishing spot }
  { 2. Click fishing spot }
  { 3. Handle inventory drops }
end;
```

### Adding Skill-Specific Tracking

Extend `TSkillProgress` for additional metrics:

```pascal
type
  TSkillProgress = record
    Skill: ERSSkill;
    CurrentLevel: UInt32;
    StartLevel: UInt32;
    TotalXP: UInt64;
    Actions: UInt64;
    IsFinished: Boolean;
    
    { Custom fields }
    ItemsProcessed: UInt64;        // Ore, logs, fish, etc.
    ProfitGenerated: Int64;        // GP made/spent
    FailureCount: UInt32;          // Skill check failures
  end;
```

### Adding Dynamic Weight Adjustment

```pascal
procedure TAIO.AdjustWeights();
var
  i: UInt32;
  avgLevel: Single;
begin
  { Boost weights for skills below average }
  avgLevel := GetAverageLevel();
  
  for i := 0 to High(Self.Activities) do
    if Self.SkillProgression[i].CurrentLevel < Trunc(avgLevel) then
      Self.Activities[i].Weight := Self.Activities[i].Weight * 1.5;
end;
```

---

## State Machine

### States and Transitions

```
┌──────────┐
│  LOGIN   │  → Authenticate user
└────┬─────┘
     │
     v
┌──────────────────┐
│ SELECT_ACTIVITY  │  → Choose next activity based on weights
└────┬─────────────┘
     │
     v
┌──────────────────┐
│ EXECUTE_ACTIVITY │  → Run skill-specific code
└────┬─────────────┘
     │
     ├─→ LEVEL_UP → Handle level-up notification
     │
     ├─→ BREAK_TIME → Take antiban break
     │
     └─→ Check conditions:
         ├─ All skills finished? → NO_ACTIVE_SKILLS (END)
         ├─ Runtime exceeded? → MAX_TIME_REACHED (END)
         └─ Continue? → Loop to SELECT_ACTIVITY
```

### State Descriptions

| State | Trigger | Action | Next State |
|-------|---------|--------|------------|
| LOGIN | Not logged in | Call `Login.DoLogin()` | SELECT_ACTIVITY |
| SELECT_ACTIVITY | Activity switch interval elapsed | Choose new activity | EXECUTE_ACTIVITY |
| EXECUTE_ACTIVITY | Normal operation | Run activity code | Based on conditions |
| LEVEL_UP | Chat level notification | Handle popup | SELECT_ACTIVITY |
| BREAK_TIME | Antiban break triggered | Sleep for duration | SELECT_ACTIVITY |
| NO_ACTIVE_SKILLS | All targets reached | Print summary, END | EXIT |
| MAX_TIME_REACHED | Runtime exceeded | Print summary, END | EXIT |

---

## Progress Tracking

### Real-Time Reporting

The framework provides a progress report showing:

```
Script Runtime:      00:30:45
Botting Runtime:     00:29:15
Antiban Runtime:     00:28:50
Total Actions:       2,450
Active Activity:     Fishing
Next Skill Switch:   345s
```

### Detailed Skill Summary

```
=== SKILL PROGRESSION ===
Woodcutting: Level 45/99 | Actions: 612
Fishing: Level 52/99 | Actions: 758
Mining: Level 38/99 | Actions: 521
Cooking: Level 61/99 | Actions: 559
=========================
```

### Printing Progress

```pascal
{ Print summary anytime }
AIOBot.PrintSkillProgress();

{ Automatically printed when:
  - All skills reach targets
  - Runtime limit reached
  - Bot finishes }
```

---

## Configuration Management

### Persistent Storage

The form automatically saves settings to JSON:

```
scripts/all-in-one-bot/config.json
```

### Accessing Saved Settings

```pascal
var AIOConfig: TConfigJSON;

begin
  AIOConfig.Setup('scripts' + PATH_SEP + 'all-in-one-bot');
  
  { Load settings }
  if AIOConfig.Data.Has('fishing_enabled') then
    FishingEnabled := AIOConfig.Data.Item['fishing_enabled'].AsBool;
  
  { Save settings }
  AIOConfig.Data.AddBool('fishing_enabled', True);
  AIOConfig.Save();
end;
```

### Form Configuration Options

```pascal
{ Enable/Disable Activities }
ActivityCheckbox.SetChecked(True);    // Toggle activity

{ Set Target Levels }
TargetLevelEdit.Text := '99';         // Target level per skill

{ Runtime Settings }
Goals.Time.Value := 5;                // Hours to run
Goals.Actions.Value := 10000;         // Max actions
Goals.Level.Value := 99;              // Max level
```

---

## Performance Considerations

### Optimization Tips

1. **Activity Switch Frequency**: Balance responsiveness vs. overhead
   - Too frequent: Constant switching hurts efficiency
   - Too infrequent: Miss completion opportunities
   - Recommendation: 10-20 minutes per activity

2. **Array Operations**: Minimize loop overhead
   - Cache enabled activity indices
   - Use early exit conditions
   - Avoid nested loops in main cycle

3. **Antiban Configuration**: Tune break chance carefully
   - 5-10% break chance per cycle is typical
   - Adjust based on activity duration
   - Consider detection risk vs. automation cost

4. **Progress Tracking**: Only track necessary metrics
   - Every level check adds ~5-10ms
   - Cache `GetLevel()` results when possible
   - Update progressively, not all-at-once

---

## Troubleshooting

### Activities Not Switching

**Problem**: Bot stays on one activity too long

**Solutions**:
1. Check `ActivitySwitchInterval` value
2. Verify all activities have `Enabled := True`
3. Confirm target levels are reachable
4. Check `GetState()` returns `SELECT_ACTIVITY`

### Progress Not Updating

**Problem**: Skill levels not changing

**Solutions**:
1. Verify `UpdateSkillProgress()` is called
2. Check `ExecuteActivity()` implementation
3. Ensure `Stats.GetLevel()` returns valid values
4. Confirm activity performs valid actions

### Bot Not Switching Activities on Level Up

**Problem**: Bot ignores level-ups

**Solutions**:
1. Verify `Chat.LeveledUp()` works
2. Check level-up state handling
3. Ensure activity switch happens after level-up
4. Test with manual level-up

---

## Best Practices

1. **Always implement activity execution logic** - Placeholder code won't progress skills
2. **Test each activity independently first** - Verify logic before adding to AIO bot
3. **Use reasonable switch intervals** - Balance variety with efficiency
4. **Monitor early runs** - Watch first hour to catch bugs
5. **Set appropriate target levels** - Don't overestimate achievable levels
6. **Configure antiban realistically** - Match your game patterns
7. **Save configuration regularly** - Use form to persist settings
8. **Document custom activities** - Make code readable for maintenance

---

## File Location

```
WaspLib-2000/examples/all_in_one_bot.simba
```

Start your custom bot by copying this file and modifying the activity execution procedures.

---

**Last Updated**: December 2025
**Framework Version**: 1.0
**WaspLib Compatibility**: 2000+
