# raycast-move-cursor-next-display - Raycast Cursor Display Switcher
Raycast Extension + TypeScript + Swift + AppKit/CoreGraphics

<directory>
assets/ - Runtime assets and native helper source (0 subdirectories)
src/ - Raycast command entrypoints (0 subdirectories)
</directory>

<config>
package.json - Raycast manifest, npm scripts, and dependency contract.
tsconfig.json - Strict TypeScript compiler settings for command code.
README.md - Setup, permissions, failure modes, and enhancement path.
.gitignore - Local ignore rules.
</config>

Architecture:
Raycast owns invocation and user feedback. The Swift helper owns macOS display geometry and cursor movement. The boundary is one command family: `assets/move-cursor next|previous [relative|center]`.

Development Standard:
Keep TypeScript as a thin adapter. Keep display math inside Swift. After changing exports, files, or responsibilities, update L3 headers first, then this map.
