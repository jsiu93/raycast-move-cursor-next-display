/**
 * [INPUT]: Depends on CoreGraphics display APIs and current mouse event location.
 * [OUTPUT]: Provides `next|previous [relative|center]` CLI commands that move the cursor across displays.
 * [POS]: Native helper for the Raycast command, owning macOS display geometry and cursor movement.
 * [PROTOCOL]: Update this header when changed, then check agents.md
 */

import AppKit
import CoreGraphics
import Foundation

struct Display {
  let id: CGDirectDisplayID
  let bounds: CGRect
}

enum Direction: String {
  case next
  case previous

  var offset: Int {
    switch self {
    case .next:
      return 1
    case .previous:
      return -1
    }
  }

  func successMessage(placement: Placement) -> String {
    let target = placement == .center ? " display center." : " display."

    switch self {
    case .next:
      return "Cursor moved to next" + target
    case .previous:
      return "Cursor moved to previous" + target
    }
  }
}

enum Placement: String {
  case relative
  case center
}

enum HelperError: Error {
  case usage
  case noDisplays
  case noMouseLocation
  case warpFailed(CGError)

  var exitCode: Int32 {
    switch self {
    case .usage:
      return 64
    case .noDisplays, .noMouseLocation:
      return 70
    case .warpFailed:
      return 71
    }
  }

  var message: String {
    switch self {
    case .usage:
      return "Usage: move-cursor next|previous [relative|center]"
    case .noDisplays:
      return "No active displays were detected."
    case .noMouseLocation:
      return "Could not read the current mouse position."
    case .warpFailed:
      return "macOS rejected cursor movement. Grant Accessibility permission to Raycast and try again."
    }
  }
}

func writeError(_ message: String) {
  let data = Data((message + "\n").utf8)
  FileHandle.standardError.write(data)
}

func activeDisplays() throws -> [Display] {
  var count: UInt32 = 0
  guard CGGetActiveDisplayList(0, nil, &count) == .success else {
    throw HelperError.noDisplays
  }

  var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
  guard CGGetActiveDisplayList(count, &ids, &count) == .success else {
    throw HelperError.noDisplays
  }

  return ids.prefix(Int(count)).compactMap { id in
    let bounds = CGDisplayBounds(id)
    guard bounds.width > 0, bounds.height > 0 else { return nil }
    return Display(id: id, bounds: bounds)
  }
}

func currentMouseLocation() throws -> CGPoint {
  guard let event = CGEvent(source: nil) else {
    throw HelperError.noMouseLocation
  }

  return event.location
}

func sortedDisplays(_ displays: [Display]) -> [Display] {
  displays.sorted {
    if $0.bounds.minX == $1.bounds.minX {
      return $0.bounds.minY < $1.bounds.minY
    }

    return $0.bounds.minX < $1.bounds.minX
  }
}

func contains(_ point: CGPoint, in rect: CGRect) -> Bool {
  point.x >= rect.minX && point.x < rect.maxX && point.y >= rect.minY && point.y < rect.maxY
}

func squaredDistance(from point: CGPoint, to rect: CGRect) -> CGFloat {
  let dx = point.x < rect.minX ? rect.minX - point.x : max(point.x - rect.maxX, 0)
  let dy = point.y < rect.minY ? rect.minY - point.y : max(point.y - rect.maxY, 0)
  return dx * dx + dy * dy
}

func currentDisplay(for point: CGPoint, displays: [Display]) -> Display {
  if let containingDisplay = displays.first(where: { contains(point, in: $0.bounds) }) {
    return containingDisplay
  }

  return displays.min {
    squaredDistance(from: point, to: $0.bounds) < squaredDistance(from: point, to: $1.bounds)
  } ?? Display(id: CGMainDisplayID(), bounds: CGDisplayBounds(CGMainDisplayID()))
}

func display(after current: Display, in displays: [Display], offset: Int) -> Display {
  guard let index = displays.firstIndex(where: { $0.id == current.id }) else {
    return displays[0]
  }

  return displays[(index + offset + displays.count) % displays.count]
}

func clamp(_ value: CGFloat, min minimum: CGFloat, max maximum: CGFloat) -> CGFloat {
  Swift.max(minimum, Swift.min(value, maximum))
}

func mappedPoint(_ point: CGPoint, from source: CGRect, to target: CGRect) -> CGPoint {
  let relativeX = (point.x - source.minX) / source.width
  let relativeY = (point.y - source.minY) / source.height
  let x = target.minX + relativeX * target.width
  let y = target.minY + relativeY * target.height

  return CGPoint(
    x: clamp(x, min: target.minX, max: target.maxX - 1),
    y: clamp(y, min: target.minY, max: target.maxY - 1)
  )
}

func centerPoint(in target: CGRect) -> CGPoint {
  CGPoint(x: target.midX, y: target.midY)
}

func destinationPoint(_ point: CGPoint, from source: CGRect, to target: CGRect, placement: Placement) -> CGPoint {
  switch placement {
  case .relative:
    return mappedPoint(point, from: source, to: target)
  case .center:
    return centerPoint(in: target)
  }
}

func moveCursor(_ direction: Direction, placement: Placement) throws -> String {
  let displays = sortedDisplays(try activeDisplays())
  guard !displays.isEmpty else { throw HelperError.noDisplays }
  guard displays.count > 1 else { return "Only one display detected." }

  let mouse = try currentMouseLocation()
  let source = currentDisplay(for: mouse, displays: displays)
  let target = display(after: source, in: displays, offset: direction.offset)
  let destination = destinationPoint(mouse, from: source.bounds, to: target.bounds, placement: placement)
  let result = CGWarpMouseCursorPosition(destination)

  guard result == .success else {
    throw HelperError.warpFailed(result)
  }

  return direction.successMessage(placement: placement)
}

func run(arguments: [String]) throws -> String {
  guard arguments.count == 2 || arguments.count == 3 else {
    throw HelperError.usage
  }

  guard let direction = Direction(rawValue: arguments[1]) else {
    throw HelperError.usage
  }

  let placement = arguments.count == 3 ? Placement(rawValue: arguments[2]) : .relative
  guard let placement else {
    throw HelperError.usage
  }

  return try moveCursor(direction, placement: placement)
}

do {
  print(try run(arguments: CommandLine.arguments))
  exit(0)
} catch let error as HelperError {
  writeError(error.message)
  exit(error.exitCode)
} catch {
  writeError("Unexpected cursor movement failure.")
  exit(1)
}
