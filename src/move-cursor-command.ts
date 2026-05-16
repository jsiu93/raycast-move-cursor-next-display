/**
 * [INPUT]: Depends on @raycast/api toasts and swift:../swift/movecursor native bridge.
 * [OUTPUT]: Provides runMoveCursor(direction, placement) and showMoveCursorToast(...) for no-view command entrypoints.
 * [POS]: src shared adapter, centralizing Swift bridge invocation, toast feedback, and user-facing errors.
 * [PROTOCOL]: Update this header when changed, then check agents.md
 */

import { showToast, Toast } from "@raycast/api";
import { moveCursor } from "swift:../swift/movecursor";

export type MoveDirection = "next" | "previous";
export type MovePlacement = "relative" | "center";

function fallbackMessage(direction: MoveDirection, placement: MovePlacement): string {
  return placement === "center" ? `Cursor moved to ${direction} display center.` : `Cursor moved to ${direction} display.`;
}

export async function runMoveCursor(direction: MoveDirection, placement: MovePlacement = "relative"): Promise<string> {
  return (await Promise.resolve(moveCursor(direction, placement))) || fallbackMessage(direction, placement);
}

export function messageFor(error: unknown): string {
  if (error instanceof Error) return error.message;
  return "Unknown cursor movement failure.";
}

export async function showMoveCursorToast(direction: MoveDirection, placement: MovePlacement = "relative"): Promise<void> {
  const toast = await showToast({
    style: Toast.Style.Animated,
    title: "Moving cursor",
  });

  try {
    const message = await runMoveCursor(direction, placement);
    toast.style = Toast.Style.Success;
    toast.title = message;
  } catch (error) {
    toast.style = Toast.Style.Failure;
    toast.title = "Could not move cursor";
    toast.message = messageFor(error);
  }
}
