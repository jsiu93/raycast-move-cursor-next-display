# Move Cursor Displays

Raycast extension plus a local Swift helper binary for moving the macOS mouse cursor between displays. The commands have no UI: run one command and the cursor jumps immediately.

## What It Does

- Reads the current cursor position.
- Finds the display containing the cursor.
- Sorts displays left to right, then top to bottom when `x` is equal.
- Moves to the next or previous display, wrapping at either end.
- Preserves the cursor's relative `x` and `y` position inside the display.
- Supports center commands that move to the target display center instead.
- Clamps the final point inside the target display bounds.
- Shows a readable message when there is only one display.

## Project Structure

```text
.
├── assets
│   ├── icon.png
│   └── move-cursor.swift
├── src
│   ├── move-cursor-command.ts
│   ├── move-cursor-next-display-center.ts
│   ├── move-cursor-next-display.ts
│   ├── move-cursor-previous-display-center.ts
│   └── move-cursor-previous-display.ts
├── package.json
├── tsconfig.json
└── README.md
```

`assets/move-cursor.swift` is source code. Compile it into `assets/move-cursor`, which is what the Raycast commands execute.

## Setup

1. Create a Raycast extension:

   ```bash
   npm create raycast-extension@latest
   ```

2. Choose a no-view TypeScript extension, then replace the generated files with this project's files.

3. Install dependencies:

   ```bash
   npm install
   ```

4. Compile the Swift helper:

   ```bash
   npm run build:helper
   ```

   This creates `assets/move-cursor`. The TypeScript command expects the executable at exactly that path inside Raycast's bundled assets directory.

5. Run the extension in Raycast development mode:

   ```bash
   npm run dev
   ```

6. In Raycast, run one of:

   ```text
   Move Cursor to Next Display
   Move Cursor to Previous Display
   Move Cursor to Next Display Center
   Move Cursor to Previous Display Center
   ```

## Permissions

The helper uses CoreGraphics and `CGWarpMouseCursorPosition`. If macOS blocks cursor movement, grant permission in:

```text
System Settings > Privacy & Security > Accessibility
```

Add Raycast while developing. If running the helper directly from Terminal, add your terminal app too.

## Common Failures

- `Helper binary is missing`: run `npm run build:helper`.
- `Helper binary is not executable`: run `chmod +x assets/move-cursor`.
- `Only one display detected`: macOS currently reports a single active display.
- `macOS rejected cursor movement`: grant Accessibility permission to Raycast and try again.

## Notes

Bundling a native executable in a Raycast extension is useful for personal workflows, but it can complicate distribution and review. For local use, keeping the compiled helper in `assets/move-cursor` is straightforward. For public distribution, verify Raycast Store policy and signing/notarization expectations before shipping.

## Next Steps

- Add preferences for display sorting strategy.
- Add more commands backed by the same Swift helper.
- Add keyboard shortcut recommendations for each command.
