/**
 * [INPUT]: Depends on @raycast/api assets path/toasts and Node child_process execution.
 * [OUTPUT]: Provides runMoveCursor(direction, placement) and showMoveCursorToast(...) for no-view command entrypoints.
 * [POS]: src shared adapter, centralizing helper discovery, execution, toast feedback, and user-facing errors.
 * [PROTOCOL]: Update this header when changed, then check agents.md
 */

import { environment, showToast, Toast } from "@raycast/api";
import { execFile } from "node:child_process";
import { constants } from "node:fs";
import { access, stat } from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";

export type MoveDirection = "next" | "previous";
export type MovePlacement = "relative" | "center";

const execFileAsync = promisify(execFile);
const HELPER_NAME = "move-cursor";

export class UserFacingError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "UserFacingError";
  }
}

async function executablePath(): Promise<string> {
  const binaryPath = path.join(environment.assetsPath, HELPER_NAME);
  const file = await stat(binaryPath).catch(() => undefined);

  if (!file) {
    throw new UserFacingError("Helper binary is missing. Run `npm run build:helper` first.");
  }

  if (!file.isFile()) {
    throw new UserFacingError("Helper path exists but is not a file.");
  }

  try {
    await access(binaryPath, constants.X_OK);
    return binaryPath;
  } catch {
    throw new UserFacingError("Helper binary is not executable. Run `chmod +x assets/move-cursor`.");
  }
}

function cleanMessage(value: string | undefined): string {
  return value?.trim().replace(/\s+/g, " ") ?? "";
}

function fallbackMessage(direction: MoveDirection, placement: MovePlacement): string {
  return placement === "center" ? `Cursor moved to ${direction} display center.` : `Cursor moved to ${direction} display.`;
}

export async function runMoveCursor(direction: MoveDirection, placement: MovePlacement = "relative"): Promise<string> {
  const binaryPath = await executablePath();

  try {
    const { stdout } = await execFileAsync(binaryPath, [direction, placement], { timeout: 5000 });
    return cleanMessage(stdout) || fallbackMessage(direction, placement);
  } catch (error) {
    if (error instanceof Error && "stderr" in error) {
      const stderr = cleanMessage(String(error.stderr));
      if (stderr) throw new UserFacingError(stderr);
    }

    throw error;
  }
}

export function messageFor(error: unknown): string {
  if (error instanceof UserFacingError) return error.message;
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
