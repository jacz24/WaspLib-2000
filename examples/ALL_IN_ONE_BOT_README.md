# All-In-One Bot Framework

A powerful, flexible bot framework for WaspLib that enables multiple skills to be trained simultaneously with intelligent activity switching and comprehensive progress tracking.

## Quick Links

- **Full Documentation**: [ALL_IN_ONE_BOT_GUIDE.md](ALL_IN_ONE_BOT_GUIDE.md)
- **Main Framework**: [all_in_one_bot.simba](all_in_one_bot.simba)
- **Quick Start Template**: [all_in_one_bot_quickstart.simba](all_in_one_bot_quickstart.simba)

## Features

✨ **Multi-Skill Support**
- Train unlimited skills simultaneously
- Independent progression tracking for each skill
- Dynamic activity switching between skills

🎯 **Intelligent Activity Selection**
- Weighted random selection system
- Configurable switch intervals
- Completion-aware (skips finished skills)

📊 **Comprehensive Tracking**
- Real-time level monitoring
- Action counting per skill
- Total runtime and session metrics
- Persistent configuration saving

🛡️ **Antiban Integration**
- Probabilistic break triggering
- Configurable break durations
- Full WaspLib antiban system support

⚙️ **Highly Extensible**
- Modular activity system
- Easy to add new skills
- Custom state handlers supported
- Flexible progress reporting

## Getting Started

### Option 1: Quick Start (Recommended)

Use the quick-start template for rapid setup:

```pascal
{$I WaspLib/osrs.simba}
{$I examples/all_in_one_bot_quickstart.simba}

{ Your custom activity implementations go here }
procedure DoWoodcutting();
begin
  { Implement woodcutting logic }
end;

procedure DoFishing();
begin
  { Implement fishing logic }
end;
```

### Option 2: Full Framework

For advanced customization:

```pascal
{$I WaspLib/osrs.simba}
{$I examples/all_in_one_bot.simba}

{ Override ExecuteActivity for custom behavior }
procedure TAIO.ExecuteActivity();
begin
  { Your logic here }
end;
```

## Basic Usage

### 1. Setup Activities

```pascal
var AIOBot: TAIO;

begin
  AIOBot.Setup(5 * ONE_HOUR);  { Run for 5 hours }
  
  { Add activities: Name, Skill, Target Level, Weight }
  AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 60, 25);
  AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 60, 25);
  AIOBot.AddActivity('Mining', ERSSkill.MINING, 60, 25);
end;
```

### 2. Configure Behavior

```pascal
{ Activity switch interval (default: 10 minutes) }
AIOBot.ActivitySwitchInterval := 15 * ONE_MINUTE;

{ Antiban break chance per cycle (0.0 to 1.0) }
AIOBot.AntibanBreakChance := 0.08;  { 8% chance }

{ Break duration range [min, max] in milliseconds }
AIOBot.BreakDuration := [2 * ONE_MINUTE, 8 * ONE_MINUTE];
```

### 3. Run the Bot

```pascal
AIOBot.Run();  { Main bot loop }
```

## Architecture Overview

### Core Components

```
┌─────────────────────────────────────┐
│      TAIO Bot Controller            │
├─────────────────────────────────────┤
│ ├─ Activities Array                 │
│ ├─ Skill Progression Trackers        │
│ ├─ State Machine                    │
│ └─ Runtime Metrics                  │
└─────────────────────────────────────┘
           │
    ┌──────┼──────┐
    v      v      v
┌────────┐ ┌───────────┐ ┌──────────┐
│Activity│ │   Skill   │ │ Progress │
│Config  │ │ Tracker   │ │ Reporter │
└────────┘ └───────────┘ └──────────┘
```

### State Machine

The bot cycles through these states:

1. **LOGIN** - Authenticate user
2. **SELECT_ACTIVITY** - Choose next skill based on weights
3. **EXECUTE_ACTIVITY** - Perform skill action
4. **LEVEL_UP** - Handle level notifications
5. **BREAK_TIME** - Take antiban break
6. **END_SCRIPT** - Cleanup and exit

## Configuration Examples

### Balanced Multi-Skill

```pascal
{ Equal weight = equal time }
AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 99, 25);
AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 99, 25);
AIOBot.AddActivity('Mining', ERSSkill.MINING, 99, 25);
AIOBot.AddActivity('Cooking', ERSSkill.COOKING, 99, 25);
```

### Prioritized Skills

```pascal
{ Spend 50% time on primary, 25% each on secondaries }
AIOBot.AddActivity('Woodcutting', ERSSkill.WOODCUTTING, 99, 50);
AIOBot.AddActivity('Fishing', ERSSkill.FISHING, 99, 25);
AIOBot.AddActivity('Mining', ERSSkill.MINING, 99, 25);
```

### High Antiban

```pascal
{ Frequent, longer breaks for safer botting }
AIOBot.AntibanBreakChance := 0.15;  { 15% break chance }
AIOBot.BreakDuration := [5 * ONE_MINUTE, 15 * ONE_MINUTE];
AIOBot.ActivitySwitchInterval := 8 * ONE_MINUTE;
```

## Implementing Activities

### Simple Activity Example

```pascal
procedure DoWoodcutting();
begin
  { 1. Find nearest axe in inventory }
  if InventoryContains(AXE_ID) then
  begin
    { 2. Click nearest tree }
    ClickTree();
    
    { 3. Wait for animation }
    WaitForAnimation(1000, 3000);
    
    { 4. Handle full inventory }
    if Inventory.Full() then
      BankLogs();
  end;
end;
```

### Using Activity Switching

```pascal
procedure TAIO.ExecuteActivity();
var
  activity: TActivityConfig;
begin
  activity := Self.Activities[Self.CurrentActivityIdx];
  
  case activity.Name of
    'Woodcutting':
    begin
      DoWoodcutting();
    end;
    
    'Fishing':
    begin
      DoFishing();
    end;
  end;
  
  Self.UpdateSkillProgress(Self.CurrentActivityIdx);
end;
```

## Monitoring Progress

### Real-Time Display

The bot shows a live progress report:

```
Script Runtime:      01:23:45
Botting Runtime:     01:20:15
Antiban Runtime:     01:19:50
Total Actions:       5,234
Active Activity:     Fishing
Next Skill Switch:   287s
```

### Summary Output

When finished, displays detailed skill progression:

```
=== SKILL PROGRESSION ===
Woodcutting: Level 68/99 | Actions: 1,245
Fishing: Level 75/99 | Actions: 1,587
Mining: Level 52/99 | Actions: 987
Cooking: Level 82/99 | Actions: 1,415
=========================
```

### Manual Printing

```pascal
{ Print progress anytime }
AIOBot.PrintSkillProgress();
```

## Advanced Features

### Conditional Activity Enabling

```pascal
{ Disable activities based on conditions }
if Stats.GetLevel(ERSSkill.FISHING) >= 85 then
  AIOBot.EnableActivity('Fishing', False);

{ Re-enable later }
AIOBot.EnableActivity('Fishing', True);
```

### Dynamic Weight Adjustment

```pascal
procedure AdjustWeightsForBalance();
var
  i: UInt32;
  avgLevel: Single := GetAverageLevel();
begin
  { Boost weights for lower skills }
  for i := 0 to High(AIOBot.SkillProgression) do
    if AIOBot.SkillProgression[i].CurrentLevel < Trunc(avgLevel) then
      AIOBot.Activities[i].Weight := AIOBot.Activities[i].Weight * 1.25;
end;
```

### Custom Progress Tracking

```pascal
{ Extend TSkillProgress in your implementation }
type
  TSkillProgress = record
    Skill: ERSSkill;
    CurrentLevel: UInt32;
    StartLevel: UInt32;
    TotalXP: UInt64;
    Actions: UInt64;
    IsFinished: Boolean;
    
    { Custom fields }
    ItemsProcessed: UInt64;
    ProfitGenerated: Int64;
  end;
```

## Best Practices

✅ **DO:**
- Test activities individually before adding to the bot
- Use realistic target levels
- Configure breaks appropriately for your play style
- Monitor the first hour of execution
- Save configurations regularly through the GUI
- Document your activity implementations

❌ **DON'T:**
- Use unrealistic target levels (99 for all skills immediately)
- Set activity switch intervals too short (<5 minutes)
- Ignore antiban configuration
- Leave placeholder activity code in production
- Run multiple bots on same account simultaneously
- Modify progress arrays directly during execution

## Performance Tips

1. **Activity Switch Interval**: 10-15 minutes is optimal
   - Too frequent: Constant overhead
   - Too infrequent: Miss completion opportunities

2. **Antiban Configuration**: 5-10% break chance per cycle
   - Adjust based on activity and detection risk

3. **Progress Tracking**: Cache level checks
   - Only call `Stats.GetLevel()` once per cycle
   - Store result in local variable

4. **Array Operations**: Minimize loops
   - Pre-calculate enabled activity indices
   - Use early exit conditions

## Troubleshooting

### Bot doesn't switch activities

**Problem**: Stays on one activity too long

**Solutions**:
1. Check `ActivitySwitchInterval` is set correctly
2. Verify all activities have `Enabled := True`
3. Confirm target levels are reachable

### Levels not updating

**Problem**: Skill progression not advancing

**Solutions**:
1. Verify `ExecuteActivity()` is implemented
2. Check `UpdateSkillProgress()` is called
3. Ensure activity actually performs valid actions

### Bot ends prematurely

**Problem**: Exits before expected time

**Solutions**:
1. Check `MaxRuntime` setting
2. Verify target levels aren't too low
3. Check for errors in activity implementation

## File Structure

```
examples/
├── all_in_one_bot.simba              # Main framework
├── all_in_one_bot_quickstart.simba   # Quick start template
├── ALL_IN_ONE_BOT_README.md          # This file
└── ALL_IN_ONE_BOT_GUIDE.md           # Full documentation
```

## What's Included

### all_in_one_bot.simba (Main Framework)
- Complete TAIO bot implementation
- State machine logic
- Activity management system
- Progress tracking
- GUI form setup
- ~450 lines of production-ready code

### all_in_one_bot_quickstart.simba (Quick Start)
- Ready-to-use template
- 4 example activities (stubs)
- Customization guide
- Configuration examples
- ~200 lines with extensive comments

### ALL_IN_ONE_BOT_GUIDE.md (Full Documentation)
- Architecture overview
- Data structure documentation
- Step-by-step implementation guide
- State machine diagrams
- Performance optimization tips
- Troubleshooting guide

## Version History

### v1.0 (Current)
- Initial release
- Multi-skill support
- Weighted activity selection
- Comprehensive progress tracking
- Full antiban integration
- GUI configuration system

## Support

For issues or questions:

1. Check [ALL_IN_ONE_BOT_GUIDE.md](ALL_IN_ONE_BOT_GUIDE.md) for detailed documentation
2. Review troubleshooting section
3. Examine example implementations
4. Check WaspLib documentation for library functions

## License

This framework follows the same license as WaspLib-2000. See the repository LICENSE file for details.

## Credits

Built for WaspLib by jacz24

Framework designed to provide a flexible, extensible foundation for multi-skill bot development.

---

**Ready to get started?**

1. Copy `all_in_one_bot_quickstart.simba`
2. Implement your activity functions
3. Customize the configuration section
4. Run your bot!

Good luck botting! 🤖
