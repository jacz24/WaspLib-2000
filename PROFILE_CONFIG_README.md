# Profile Configuration System for WaspLib-2000

## Overview

The **Profile Configuration System** is a comprehensive profile management solution for WaspLib-2000 bots that provides:

✅ **Unified Profile Management**
- Create and manage multiple character profiles
- Store profile-specific data in persistent JSON configs
- Easy profile switching for multi-account bots

✅ **Skill Level Tracking**
- Track all 25 OSRS skills (Attack through Dungeoneering)
- Update skills during runtime as your bot progresses
- Query skill levels to make activity decisions

✅ **Quest Completion Logging**
- Mark quests as complete/incomplete
- Gate activities based on quest requirements
- Track progression towards quest-locked content

✅ **Intelligent Activity Selection**
- Let bots decide which activities to perform
- Prevent low-level characters from doing high-level activities
- Unlock advanced methods once prerequisites are met

✅ **Runtime Configuration Updates**
- Profile data updates automatically as bot progresses
- Changes persist across sessions
- No manual editing required during bot operation

---

## What Gets Created

### File 1: `osrs/profileform.simba` (Main Implementation)

The core profile management system with:

**Data Structure:**
- `TProfileFormHelper` - Complete profile management record
- JSON-based config storage
- Automatic file I/O handling

**Public API Functions:**
- `GetSkillLevel(skillName)` - Query character skills
- `UpdateSkillLevel(skillName, newLevel)` - Update skills at runtime
- `IsQuestComplete(questName)` - Check quest status
- `CompleteQuest(questName)` - Mark quests done
- `LoadProfile(profileName)` - Load profile from disk
- `SaveProfile()` - Save profile changes

**UI Components:**
- Profile management tab with New/Load/Delete buttons
- Skills panel with 25 spin edits (1-99 range)
- Quest tracking panel with dynamic list
- Full integration with `TScriptForm`

### File 2: `examples/profile_form_example.simba` (Complete Example)

Working example demonstrating:
- Integration into bot form setup
- Skill-based activity selection
- Quest prerequisite checking
- Runtime profile updates
- Multi-profile management
- Advanced decision engines

### Auto-Created: `Profiles/` Directory

Stores profile JSON files:
```
Profiles/
├── CharacterName1.json
├── CharacterName2.json
└── MyAccount.json
```

Each profile file contains:
```json
{
  "name": "Character Name",
  "account": "account@email.com",
  "created": "12/11/2025 02:00:00 AM",
  "last_updated": "12/11/2025 02:45:00 AM",
  "skills": {
    "attack": 40,
    "defence": 35,
    "strength": 42,
    "fishing": 60
  },
  "quests": {
    "cooks assistant": true,
    "waterfall quest": true,
    "dragon slayer": false
  }
}
```

---

## Quick Start

### 1. Add to Your Bot

```pascal
{$I WaspLib/osrs.simba}
{$I WaspLib/osrs/profileform.simba}  // Add this include

var
  form: TScriptForm;

begin
  form.Setup();
  form.CreateProfileTab();   // Add this line to your form
  form.CreateMiscTab();
  form.Run();
end.
```

### 2. Create a Profile (Via UI)

1. Run your bot with the updated script
2. Click the **"Profile"** tab
3. Enter a profile name (e.g., "My Fishing Bot")
4. Enter account name (optional)
5. Click **"New Profile"**
6. Set your character's skill levels (1-99 each)
7. Check which quests you've completed
8. Close the form

→ Your profile is now saved to `Profiles/My Fishing Bot.json`

### 3. Use in Your Script

```pascal
// Query a skill level
var level: Integer;
begin
  level := ProfileForm.GetSkillLevel('Fishing');
  
  if level < 20 then
    Fish('Shrimp')
  else
    Fish('Trout');
end;

// Update a skill level when bot detects levelup
ProfileForm.UpdateSkillLevel('Fishing', 21);

// Check quest status
if ProfileForm.IsQuestComplete('Waterfall Quest') then
  EquipDragonGear();

// Mark quest complete
ProfileForm.CompleteQuest('Waterfall Quest');
```

---

## API Reference

### Query Functions

#### `GetSkillLevel(skillName: String): Integer`

Returns the character's current level in a skill.

```pascal
var
  fishingLevel: Integer;
begin
  fishingLevel := ProfileForm.GetSkillLevel('Fishing');
  WriteLn('Fishing level: ' + ToStr(fishingLevel));
end;
```

**Parameters:**
- `skillName` - Any OSRS skill name (case-insensitive)

**Returns:**
- Integer 1-99 representing the skill level
- 1 if skill not found

**Available Skills:**
Attack, Defence, Strength, Hitpoints, Ranged, Prayer, Magic, Cooking, Woodcutting, Fletching, Fishing, Firemaking, Crafting, Smithing, Mining, Herblore, Agility, Thieving, Slayer, Farming, Runecrafting, Hunter, Construction, Summoning, Dungeoneering

---

#### `IsQuestComplete(questName: String): Boolean`

Checks if a quest is marked as complete.

```pascal
if ProfileForm.IsQuestComplete('Dragon Slayer') then
  WriteLn('Can use Dragon items!')
else
  WriteLn('Must complete Dragon Slayer first');
```

**Parameters:**
- `questName` - Name of the quest (case-insensitive)

**Returns:**
- `true` if quest is complete
- `false` if quest is incomplete or not found

---

### Update Functions

#### `UpdateSkillLevel(skillName: String; newLevel: Integer)`

Updates a skill level and persists to config.

```pascal
procedure OnLevelUp(skill: String; newLevel: Integer);
begin
  WriteLn('You gained a level in ' + skill + '!');
  ProfileForm.UpdateSkillLevel(skill, newLevel);
  WriteLn('Profile updated');
end;
```

**Parameters:**
- `skillName` - Skill to update
- `newLevel` - New level (1-99)

**Auto-saves to config**

---

#### `CompleteQuest(questName: String)`

Marks a quest as complete and persists to config.

```pascal
procedure OnQuestFinish(questName: String);
begin
  ProfileForm.CompleteQuest(questName);
  WriteLn(questName + ' marked as complete!');
end;
```

**Parameters:**
- `questName` - Quest to mark complete

**Auto-saves to config**

---

### Management Functions

#### `LoadProfile(profileName: String)`

Loads a profile from disk.

```pascal
ProfileForm.LoadProfile('My Fishing Bot');
WriteLn('Profile loaded: ' + ProfileForm.CurrentProfile);
```

---

#### `SaveProfile()`

Manually saves profile to disk. (Usually called automatically.)

```pascal
ProfileForm.SaveProfile();
```

---

#### `RefreshProfileList()`

Reloads available profiles from the Profiles directory.

```pascal
ProfileForm.RefreshProfileList();
```

---

#### `Setup()`

Initializes the profile system.

```pascal
ProfileForm.Setup();
```

---

## Common Usage Patterns

### Pattern 1: Skill-Based Activity Routing

Select activities based on skill levels:

```pascal
procedure SelectActivity();
var
  fishLevel, wc_level: Integer;
begin
  fishLevel := ProfileForm.GetSkillLevel('Fishing');
  wc_level := ProfileForm.GetSkillLevel('Woodcutting');
  
  // Train the lower skill
  if fishLevel < wc_level then
    RunFishingBot()
  else
    RunWoodcuttingBot();
end;
```

### Pattern 2: Quest-Gated Content

Unlock advanced methods only after quest requirements:

```pascal
procedure RunFishing();
begin
  if ProfileForm.GetSkillLevel('Fishing') < 20 then
  begin
    Fish('Shrimp');
  end
  else if ProfileForm.IsQuestComplete('Waterfall Quest') then
  begin
    Fish('Monkfish');  // Better XP
  end
  else
  begin
    Fish('Trout');
  end;
end;
```

### Pattern 3: Session Progress Tracking

Update profile at end of session:

```pascal
procedure OnSessionEnd();
var
  finalLevel: Integer;
begin
  finalLevel := ReadActualLevelFromGame();
  ProfileForm.UpdateSkillLevel('Fishing', finalLevel);
  WriteLn('Profile updated with final stats');
end;
```

### Pattern 4: Multi-Profile Bot Selection

Run different bots based on profile name:

```pascal
procedure SelectBot();
var
  profile: String;
begin
  profile := ProfileForm.CurrentProfile;
  
  if pos('Fishing', profile) > 0 then
    RunFishingBot()
  else if pos('Combat', profile) > 0 then
    RunCombatBot()
  else if pos('Skilling', profile) > 0 then
    RunSkillingBot()
  else
    RunGeneralBot();
end;
```

---

## FAQ

### Q: How do I create a new profile?
**A:** Run your bot with the Profile Tab in the form, enter a profile name, click "New Profile", then set your skill levels and quests.

### Q: Can I have multiple profiles?
**A:** Yes! Each profile is a separate JSON file in the `Profiles/` directory. You can switch between them by clicking "Load".

### Q: Do changes save automatically?
**A:** Yes! When you change skill levels or quest status, changes are saved immediately to the JSON file.

### Q: Can I edit profile files manually?
**A:** Yes! Profile JSON files are plain text and can be edited with any text editor. Changes take effect on next profile load.

### Q: What happens if I don't create a profile?
**A:** The form will work but `CurrentProfile` will be empty. Functions like `GetSkillLevel()` will return default values (1 for skills, false for quests).

### Q: Can I use this with multiple bots?
**A:** Absolutely! Each bot can load different profiles, making it perfect for multi-account botting.

### Q: Where are profiles stored?
**A:** In the `Profiles/` directory relative to your Simba folder: `Simba/Profiles/ProfileName.json`

### Q: Can I delete a profile?
**A:** Yes! Select the profile in the list and click "Delete", or manually delete the JSON file from the Profiles directory.

### Q: Do I need to manually manage JSON files?
**A:** No! The UI handles all JSON operations. Manual editing is optional for advanced users.

---

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Profile won't save | Profiles/ directory doesn't exist | Create `Profiles/` folder manually |
| "Profile not found" | Profile JSON deleted | Create profile again via UI |
| Skill level resets | No profile loaded | Load profile with `LoadProfile()` |
| Changes not persisting | New profile not saved | Click "New Profile" button first |
| Quest not in list | Quest never added | Use "Add Quest" feature in UI |

---

## File Structure

```
Simba/
├── Includes/
│   └── WaspLib-2000/
│       ├── osrs/
│       │   ├── profileform.simba      ← Main implementation
│       │   ├── miscform.simba         ← Existing forms
│       │   └── antibanform.simba      ← Existing forms
│       └── ...
├── Profiles/                            ← Profile data directory
│   ├── FishingBot.json
│   ├── CombatAccount.json
│   └── SkillBot.json
└── ...
```

---

## Examples

Complete working examples are in `examples/profile_form_example.simba`:

1. Basic form setup
2. Activity selection by skill level
3. Quest-based progression
4. Runtime skill updates
5. Multi-profile management
6. Advanced decision engines
7. Session progress tracking
8. Quest completion handling

---

## Integration Checklist

- [ ] Include `profileform.simba` in your bot
- [ ] Add `form.CreateProfileTab()` to form setup
- [ ] Create a profile via the UI
- [ ] Test querying skill levels with `GetSkillLevel()`
- [ ] Test updating skills with `UpdateSkillLevel()`
- [ ] Use profile data to gate activities
- [ ] Mark quests complete as your bot progresses
- [ ] Verify profile JSON file is created
- [ ] Test profile persistence (reload bot, profile still there)

---

## Next Steps

1. **Integrate into one bot** - Add ProfileTab to existing bot and test
2. **Create profiles** - Set up profiles for your characters
3. **Implement activity selection** - Use skill levels to decide what to do
4. **Track progress** - Update skills and mark quests as bot runs
5. **Expand to all bots** - Copy pattern to other bots

---

## Support

- **Source Code Documentation**: See comments in `osrs/profileform.simba`
- **Working Examples**: See `examples/profile_form_example.simba`
- **API Reference**: See above in this document
- **Data Format**: Profile JSON files are human-readable

---

**Profile Configuration System Ready to Use!**

Your comprehensive profile management solution is now integrated into WaspLib-2000. Start using it to make your bots smarter and more adaptable to different character capabilities.
