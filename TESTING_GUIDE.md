# Quick Test Guide - WordFlow Improvements

## 🚀 Quick Start

### 1. Run the Application on Windows

```powershell
# Build and run on Windows (recommended for full features)
flutter run -d windows
```

**Why Windows?** Background typing and global hotkeys only work on desktop platforms.

### 2. Configure Typing Mode

1. Click the **Settings** icon (⚙️) in the bottom navigation
2. Find **"Typing Mode"** section
3. Click to open the dialog
4. Select **"Real-Time Typing"** or **"Both"**
5. Click **"Close"**

### 3. Test Background Typing

#### Scenario 1: Typing in Notepad
1. Open **Notepad**
2. Click in the text area
3. Press your hotkey (**Win+Shift+W** by default)
4. Say: "Hello world, this is a test of the background typing feature"
5. Release the hotkey or press it again (depending on behavior mode)
6. **Watch the text appear in Notepad!** ✨

#### Scenario 2: Typing Lists
1. Open any text editor
2. Click where you want to type
3. Press hotkey and say: "You have to do the following things first one is create the project second one is test it third one is deploy it"
4. Release hotkey
5. **See the formatted list appear!** 📝

Expected output:
```
You have to do the following things:
1. CREATE THE PROJECT
2. TEST IT
3. DEPLOY IT
```

### 4. Test Hotkey Customization

1. Go to **Settings**
2. Click **"Customize"** in the Hotkey section
3. Click **"Record"** button
4. Press your desired combination (e.g., **Ctrl+Shift+R**)
5. Verify it shows correctly (no extra modifiers!)
6. Click **"Save"**
7. Test the new hotkey works

### 5. Test History Editing

1. Go to **History** tab (clock icon)
2. Click on any past transcription
3. Click the **edit icon** (pencil)
4. Modify the text
5. Click the **check icon** to save
6. Reopen the same item to verify changes were saved

### 6. Test Punctuation

#### Test Questions:
- Say: "What is your name"
- Expected: "What is your name**?**"

#### Test Multiple Sentences:
- Say: "This is the first sentence this is the second sentence this is the third"
- Expected: "This is the first sentence**.** This is the second sentence**.** This is the third**.**"

#### Test Transition Words:
- Say: "I like coding however I also enjoy reading"
- Expected: "I like coding**,** however**,** I also enjoy reading**.**"

---

## 🎯 Feature Testing Matrix

### ✅ Punctuation & Formatting
| Test | Input | Expected Output | Status |
|------|-------|-----------------|--------|
| Simple sentence | "hello world" | "Hello world." | ⬜ |
| Question | "what is this" | "What is this?" | ⬜ |
| Multiple sentences | "first one second one" | "First one. Second one." | ⬜ |
| List | "first is A second is B" | "First is A:\n1. A\n2. B" | ⬜ |

### ✅ Background Typing
| Test | Application | Status |
|------|-------------|--------|
| Type in Notepad | Notepad.exe | ⬜ |
| Type in Word | Microsoft Word | ⬜ |
| Type in Browser | Chrome/Edge | ⬜ |
| Type in VS Code | Code editor | ⬜ |
| Unicode characters | "Hello 世界 🎉" | ⬜ |

### ✅ History Editing
| Test | Action | Status |
|------|--------|--------|
| Edit transcription | Modify text | ⬜ |
| Save changes | Click save | ⬜ |
| Delete item | Click delete + confirm | ⬜ |
| Cancel edit | Click close without saving | ⬜ |

### ✅ Hotkey Recording
| Test | Combination | Status |
|------|-------------|--------|
| Win+Shift+W | Default | ⬜ |
| Ctrl+Shift+R | Custom | ⬜ |
| Alt+Q | Custom | ⬜ |
| Invalid (no modifier) | Should reject | ⬜ |

### ✅ UI/Theme
| Test | Theme | Status |
|------|-------|--------|
| Light theme | Professional indigo | ⬜ |
| Dark theme | Dark gray + indigo | ⬜ |
| Cards | Clean borders | ⬜ |
| Typography | Inter font | ⬜ |

---

## 🐛 Common Issues & Solutions

### Issue 1: Hotkeys not working
**Solution**: Hotkeys only work on Windows desktop, not on web. Make sure you're running `flutter run -d windows`.

### Issue 2: Background typing not working
**Causes**:
1. Typing mode is set to "App Only" → Change to "Real-Time Typing"
2. Running on web → Must run on Windows desktop
3. Target window doesn't have focus → Click in the target window first

### Issue 3: Text not appearing correctly
**Solution**: Background typing uses SendInput API which requires the target window to be active. Make sure the window you want to type into is in focus.

### Issue 4: Hotkey recording showing wrong keys
**Solution**: This was fixed! Make sure you're on the latest version. Click "Record", clear any previous selection, then press your desired combination.

### Issue 5: Punctuation not working
**Causes**:
1. Speaking too fast → Pause slightly between sentences
2. Auto-punctuation disabled → Check settings
3. Need to stop recording for final punctuation → Press hotkey to finish

---

## 📊 Performance Expectations

### Typing Speed
- **Character delay**: 3ms between characters
- **1000 characters**: ~3 seconds
- **Typical sentence**: <0.5 seconds

### Speech Recognition
- **Partial results**: Real-time (100-300ms)
- **Final results**: 1-2 seconds after stopping
- **Accuracy**: Depends on microphone quality and environment

### Memory Usage
- **Idle**: ~50-100 MB
- **Active transcription**: ~100-150 MB
- **Large history (100 items)**: ~150-200 MB

---

## 🎓 Pro Tips

### Tip 1: Use Hotkey Behaviors
- **Toggle Mode**: Single press to start/stop (best for long dictation)
- **Hold to Speak**: Hold for quick notes (best for short bursts)
- **Push to Talk**: Press once, auto-stops on silence (best for voice commands)

### Tip 2: Voice Commands for Lists
Say numbers as words for better list detection:
- ✅ "first one is" "second one is" "third one is"
- ✅ "1st" "2nd" "3rd"
- ❌ Avoid saying just numbers without context

### Tip 3: Background Typing Best Practices
1. Click in target window first
2. Keep app running in background
3. Use "Real-Time Typing" for external apps
4. Use "Both" to see what's being typed
5. Use "App Only" for reviewing before copying

### Tip 4: Better Punctuation
- Pause naturally between sentences
- Speak clearly and at normal pace
- Use voice commands: "period", "question mark", "comma"

### Tip 5: Organize Your History
- Edit transcriptions to clean them up
- Delete test transcriptions
- Copy final versions to your documents

---

## 📞 Testing Workflow Example

### Scenario: Writing an Email
1. **Setup**:
   - Run app on Windows
   - Set typing mode to "Both"
   - Open Gmail in browser
   - Click in email compose field

2. **Compose**:
   - Press hotkey
   - Say: "Hello John comma I hope this email finds you well period I wanted to follow up on the project we discussed yesterday period"
   - Release hotkey
   - Watch it appear in both app and Gmail!

3. **Review**:
   - Check the transcription in the app
   - Edit if needed
   - The typed version is already in Gmail

4. **Save**:
   - Your transcription is automatically saved in History
   - Can edit later if needed

### Scenario: Creating a To-Do List
1. **Setup**:
   - Open Notepad
   - Set typing mode to "Real-Time Typing"

2. **Dictate**:
   - Press hotkey
   - Say: "My tasks for today first one is review pull requests second one is update documentation third one is fix bugs fourth one is deploy to staging"
   - Release hotkey

3. **Result** in Notepad:
   ```
   My tasks for today:
   1. REVIEW PULL REQUESTS
   2. UPDATE DOCUMENTATION
   3. FIX BUGS
   4. DEPLOY TO STAGING
   ```

---

## ✨ Enjoy Your Enhanced WordFlow!

All features are working together to give you the best speech-to-text experience with:
- ✅ Smart punctuation
- ✅ Automatic formatting
- ✅ Background typing anywhere
- ✅ Editable history
- ✅ Modern professional UI
- ✅ Reliable hotkey recording

Happy dictating! 🎤✨
