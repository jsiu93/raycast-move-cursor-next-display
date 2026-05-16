# raycast-move-cursor-next-display - Raycast Cursor Display Switcher
Raycast Extension + TypeScript + Swift + AppKit/CoreGraphics

<directory>
assets/ - Runtime assets referenced by Raycast manifest (0 subdirectories)
src/ - Raycast command entrypoints (0 subdirectories)
swift/ - Native Swift bridge packages for macOS system APIs (1 subdirectory: movecursor)
</directory>

<config>
CHANGELOG.md - Store release notes with Raycast merge-date placeholder.
package.json - Raycast manifest, npm scripts, and dependency contract.
package-lock.json - npm dependency lockfile required for reproducible Store builds.
tsconfig.json - Strict TypeScript compiler settings for command code.
README.md - Setup, permissions, failure modes, and enhancement path.
.gitignore - Local ignore rules.
</config>

Architecture:
Raycast owns invocation and user feedback. The Swift bridge package owns macOS display geometry and cursor movement. The boundary is one exported function: `moveCursor(direction, placement)`.

Development Standard:
Keep TypeScript as a thin adapter. Keep display math inside Swift. After changing exports, files, or responsibilities, update L3 headers first, then this map.
