# Text Input Field Bug Fixes

## Problem Description

The text input field in the type shader aspect control panel was experiencing severe bugs:

1. **Letters appearing in wrong order** - Characters would appear scrambled or reversed
2. **Cursor position issues** - Cursor would jump to unexpected positions
3. **Selection problems** - Text selection and deletion didn't work properly
4. **State management issues** - External updates would interfere with user typing

## Root Causes Identified

### 1. TextEditingController Recreation
- **Issue**: The original `TextInputField` was a `StatelessWidget` that created a new `TextEditingController` on every build
- **Impact**: This caused Flutter to lose track of cursor position and text state, leading to character reordering

### 2. Missing State Change Notifications
- **Issue**: The `_setCurrentText` method in `TextPanel` wasn't calling `widget.onSettingsChanged()`
- **Impact**: Changes weren't being propagated properly through the widget tree

### 3. Widget Identity Issues
- **Issue**: No unique keys for text input fields when switching between different text lines (Title, Subtitle, Artist, Lyrics)
- **Impact**: Flutter couldn't properly maintain widget state when switching between text lines

### 4. Focus Management Problems
- **Issue**: External updates could interrupt user typing by updating the controller while focused
- **Impact**: User input would be interrupted and cursor position lost

## Fixes Applied

### 1. Converted to StatefulWidget with Proper Lifecycle Management

**File**: `lib/shader_demo/widgets/text_input_field.dart`

```dart
class TextInputField extends StatefulWidget {
  // ... properties

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _lastValue = '';

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

### 2. Smart External Update Handling

```dart
@override
void didUpdateWidget(TextInputField oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // Only update if external value changed and differs from current
  if (widget.value != _lastValue && widget.value != _controller.text) {
    _lastValue = widget.value;
    
    // Only update if field is not focused (avoid interrupting user input)
    if (!_focusNode.hasFocus) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(offset: widget.value.length);
    } else {
      // If focused, preserve cursor position carefully
      final int cursorPos = _controller.selection.baseOffset;
      _controller.text = widget.value;
      
      if (cursorPos >= 0 && cursorPos <= widget.value.length) {
        _controller.selection = TextSelection.collapsed(offset: cursorPos);
      } else {
        _controller.selection = TextSelection.collapsed(offset: widget.value.length);
      }
    }
  }
}
```

### 3. Added Proper Settings Change Notification

**File**: `lib/shader_demo/widgets/text_panel.dart`

```dart
void _setCurrentText(String v) {
  // Store the text directly
  switch (selectedTextLine) {
    case TextLine.title:
      widget.settings.textLayoutSettings.textTitle = v;
      break;
    // ... other cases
  }
  
  // Ensure text is enabled when user types text
  if (v.isNotEmpty && !widget.settings.textLayoutSettings.textEnabled) {
    widget.settings.textLayoutSettings.textEnabled = true;
  }
  
  // Notify that settings have changed
  widget.onSettingsChanged(widget.settings);
}
```

### 4. Added Unique Widget Keys

```dart
TextInputField(
  key: ValueKey('text_input_${selectedTextLine.toString()}'),
  label: '${selectedTextLine.label} Text',
  value: _getCurrentText(),
  onChanged: _setCurrentText,
  // ... other properties
),
```

### 5. Improved Focus Management

```dart
child: TextFormField(
  controller: _controller,
  focusNode: _focusNode,  // Added focus node
  // ... other properties
  onChanged: (txt) {
    _lastValue = txt;
    widget.onChanged(txt);
    // ... rest of logic
  },
),
```

## Testing

Created comprehensive tests in `test/text_input_field_test.dart` to verify:

1. **Text state maintenance** - Ensures text input maintains state correctly
2. **External value updates** - Verifies external updates work without breaking user input
3. **Multiline support** - Tests multiline text functionality

All tests pass successfully.

## Additional Notes

### About the "Conversation Type" Errors

The "Unexpected missing conversation type" errors mentioned in the original issue are likely coming from external dependencies or Flutter framework logs, not from the text input code itself. These errors don't appear in the codebase and are probably unrelated to the text input issues.

### Performance Improvements

The fixes also include performance improvements:
- Proper widget lifecycle management reduces unnecessary rebuilds
- Focus-aware updates prevent interrupting user input
- Unique keys ensure Flutter can efficiently manage widget state

## Verification

To verify the fixes work:

1. Run the tests: `flutter test test/text_input_field_test.dart`
2. Test the app manually by:
   - Typing in different text fields (Title, Subtitle, Artist, Lyrics)
   - Switching between text lines while typing
   - Using text selection and deletion
   - Verifying characters appear in correct order

The text input should now work smoothly without character reordering, cursor jumping, or selection issues. 