/**
 * [INPUT]: Depends on src/move-cursor-command's showMoveCursorToast.
 * [OUTPUT]: Provides the no-view Raycast command `move-cursor-previous-display-center`.
 * [POS]: Raycast previous-display-center command entrypoint, thin wrapper over the shared cursor command adapter.
 * [PROTOCOL]: Update this header when changed, then check agents.md
 */

import { showMoveCursorToast } from "./move-cursor-command";

export default async function Command() {
  await showMoveCursorToast("previous", "center");
}
