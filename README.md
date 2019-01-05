## The CodeBrowser makes browsing through projects with multiple files and lots of functions easy, convenient and pleasant.

#### Requirements

- Igor Pro version 6.3.0 or later

#### Installation

1. Install Igor.
2. Start Igor. This creates a folder called WaveMetrics in Documents. Close Igor.
3. Extract the zip file into a folder somewhere on your disc.
4. Create a link from `CodeBrowser-v*/procedures` to
   `Documents\WaveMetrics\Igor Pro [6-8] User Files\Igor Procedures`.
5. Start Igor. You can now find `CodeBrowser/Open` in the main menu.

#### Features

- Shows all functions/macros from a procedure file including parameter
  types, return types and special properties like static and
  threadsafe.
- Shows Menu/Constant/StrConstant/Structure entries.
- Shows the structure name for window hook and background tasks for
  easier searching.
- Allows jumping to the definition of these elements within the code by
  mouse and keyboard.
- Optionally alphabetically sorted lists.
- Shows function comments as tooltips (IP8 only).
- Works with Independent Modules.

For reasons of ease-of-use the function declarations are displayed as
`myFunction(var, str) -> var` for a function taking a variable and
string parameter and returning a variable. Programmers might recognize
this as being inspired by the trailing return types from C++11.

#### Navigation by keyboard

- <kbd>CTRL</kbd>+<kbd>0</kbd>: Open the panel.
- Jump to the definition of the listbox selection with <kbd>.<kbd>
- Pressing any character while the ListBox has the focus activates the
  first listbox entry which starts with that character.

#### Limitations

- No parameter types are shown for macros

#### Screenshot

![Screenshot](screenshot-panel.png)
