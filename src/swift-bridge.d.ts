/**
 * [INPUT]: Depends on Raycast Swift bridge module path swift:../swift/movecursor.
 * [OUTPUT]: Provides TypeScript declarations for native moveCursor export during standalone tsc checks.
 * [POS]: src type shim, mirroring the generated Swift bridge interface for local strict typechecking.
 * [PROTOCOL]: Update this header when changed, then check agents.md
 */

declare module "swift:../swift/movecursor" {
  export function moveCursor(direction: string, placement: string): string | Promise<string>;
}
