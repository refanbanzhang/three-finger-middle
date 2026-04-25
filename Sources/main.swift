import AppKit
import ApplicationServices
import CoreGraphics
import IOKit
import MultitouchSupport

@_silgen_name("MTDeviceCreateList")
func MTDeviceCreateList() -> Unmanaged<CFMutableArray>?

private enum Log {
  private static let fileURL = URL(fileURLWithPath: "/Users/rfbz/Documents/Codex/2026-04-23-mac-chrome-tab/three-finger-middle/build/ThreeFingerMiddle.log")

  static func info(_ message: String) {
    let line = "[ThreeFingerMiddle] \(message)\n"
    print(line, terminator: "")
    if let data = line.data(using: .utf8) {
      if FileManager.default.fileExists(atPath: fileURL.path) {
        if let handle = try? FileHandle(forWritingTo: fileURL) {
          try? handle.seekToEnd()
          try? handle.write(contentsOf: data)
          try? handle.close()
        }
      } else {
        try? data.write(to: fileURL)
      }
    }
  }
}

private final class TouchDeviceManager {
  private var devices: [MTDevice] = []

  func start(callback: @escaping MTFrameCallbackFunction) {
    registerCurrentDevices(callback: callback)
  }

  func restart(callback: @escaping MTFrameCallbackFunction) {
    stop(callback: callback)
    registerCurrentDevices(callback: callback)
  }

  func stop(callback: @escaping MTFrameCallbackFunction) {
    devices.forEach {
      _ = $0.unregister(contactFrameCallback: callback)
      $0.stop()
      $0.release()
    }
    devices.removeAll()
  }

  private func registerCurrentDevices(callback: @escaping MTFrameCallbackFunction) {
    devices = (MTDeviceCreateList()?.takeUnretainedValue() as? [MTDevice]) ?? []
    for device in devices {
      _ = device.register(contactFrameCallback: callback)
      device.start(runMode: 0)
    }
    Log.info("registered \(devices.count) multitouch device(s)")
  }
}

private final class ThreeFingerTapRecognizer {
  static let shared = ThreeFingerTapRecognizer()

  private let requiredFingers: Int32 = 3
  private let maxTapDuration: TimeInterval = 0.30
  private let maxDistanceDelta: Float = 0.05
  private let dedupeInterval: TimeInterval = 0.30 * 0.3

  private var touchStartTime: Date?
  private var maybeMiddleClick = false
  private var hasRecordedStart = false
  private var startCentroid = SIMD2<Float>.zero
  private var endCentroid = SIMD2<Float>.zero
  private var lastEmulatedAt: Date?

  let callback: MTFrameCallbackFunction = { _, touches, fingerCount, _, _ in
    Task { @MainActor in
      ThreeFingerTapRecognizer.shared.handleFrame(touches: touches, fingerCount: fingerCount)
    }
  }

  func handleFrame(touches: UnsafeMutablePointer<MTTouch>?, fingerCount: Int32) {
    if fingerCount == 0 {
      handleTouchEnd()
      return
    }

    let isStart = touchStartTime == nil
    if isStart {
      touchStartTime = Date()
      maybeMiddleClick = true
      hasRecordedStart = false
    } else if maybeMiddleClick, let startTime = touchStartTime,
              -startTime.timeIntervalSinceNow > maxTapDuration {
      maybeMiddleClick = false
    }

    if fingerCount < requiredFingers { return }

    if fingerCount > requiredFingers {
      maybeMiddleClick = false
      hasRecordedStart = false
      return
    }

    guard let touches else { return }
    let centroid = centroidOfFirst(touches, count: Int(requiredFingers))

    if !hasRecordedStart {
      startCentroid = centroid
      endCentroid = centroid
      hasRecordedStart = true
    } else {
      endCentroid = centroid
    }
  }

  private func handleTouchEnd() {
    defer {
      touchStartTime = nil
      maybeMiddleClick = false
      hasRecordedStart = false
      startCentroid = .zero
      endCentroid = .zero
    }

    guard let startTime = touchStartTime, hasRecordedStart else { return }
    let elapsed = -startTime.timeIntervalSinceNow
    guard elapsed <= maxTapDuration else {
      Log.info("gesture rejected, elapsed \(String(format: "%.3f", elapsed))s")
      return
    }

    let delta = abs(startCentroid.x - endCentroid.x) + abs(startCentroid.y - endCentroid.y)
    guard delta < maxDistanceDelta else {
      Log.info("gesture rejected, movement \(String(format: "%.4f", delta))")
      return
    }

    if let last = lastEmulatedAt, -last.timeIntervalSinceNow < dedupeInterval {
      Log.info("gesture deduped within \(String(format: "%.3f", dedupeInterval))s")
      return
    }
    lastEmulatedAt = Date()

    Log.info("gesture recognized, posting middle click")
    postMiddleClick()
  }

  private func centroidOfFirst(_ buffer: UnsafeMutablePointer<MTTouch>, count: Int) -> SIMD2<Float> {
    var sum = SIMD2<Float>.zero
    for touch in UnsafeBufferPointer(start: buffer, count: count) {
      sum += SIMD2<Float>(touch.normalizedVector.position.x, touch.normalizedVector.position.y)
    }
    return sum / Float(count)
  }

  private func postMiddleClick() {
    let location = CGEvent(source: nil)?.location ?? .zero
    Log.info("posting middle click at \(Int(location.x)),\(Int(location.y))")
    guard
      let down = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown, mouseCursorPosition: location, mouseButton: .center),
      let up = CGEvent(mouseEventSource: nil, mouseType: .otherMouseUp, mouseCursorPosition: location, mouseButton: .center)
    else {
      Log.info("failed to create middle mouse events")
      return
    }

    down.post(tap: .cghidEventTap)
    up.post(tap: .cghidEventTap)
  }

  func postMiddleClickForTesting() {
    postMiddleClick()
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  private let touchDevices = TouchDeviceManager()

  func applicationDidFinishLaunching(_ notification: Notification) {
    setupStatusItem()
    ensureAccessibilityPrompt()
    startRecognizer()
    observeWakeNotifications()
  }

  private func setupStatusItem() {
    guard let button = statusItem.button else { return }
    button.imageScaling = .scaleProportionallyDown

    if let image = loadMenuBarIcon() {
      button.image = image
      button.imagePosition = .imageOnly
      button.title = ""
      button.toolTip = "ThreeFingerMiddle"
    } else {
      button.image = nil
      button.title = "3M"
    }

    let menu = NSMenu()
    menu.addItem(withTitle: "ThreeFingerMiddle is running", action: nil, keyEquivalent: "")
    menu.addItem(NSMenuItem.separator())

    let permissions = NSMenuItem(
      title: "Open Accessibility Settings",
      action: #selector(openAccessibilitySettings),
      keyEquivalent: ""
    )
    permissions.target = self
    menu.addItem(permissions)

    let testClick = NSMenuItem(title: "Send Test Middle Click", action: #selector(sendTestMiddleClick), keyEquivalent: "")
    testClick.target = self
    menu.addItem(testClick)

    let restart = NSMenuItem(title: "Restart Touch Listener", action: #selector(restartRecognizer), keyEquivalent: "")
    restart.target = self
    menu.addItem(restart)

    menu.addItem(NSMenuItem.separator())
    let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
    quit.target = self
    menu.addItem(quit)

    statusItem.menu = menu
  }

  private func loadMenuBarIcon() -> NSImage? {
    guard let url = Bundle.main.url(forResource: "menu-bar-full-template-master", withExtension: "png"),
          let image = NSImage(contentsOf: url) else {
      return nil
    }

    image.isTemplate = true
    image.size = NSSize(width: 18, height: 18)
    return image
  }

  private func startRecognizer() {
    touchDevices.start(callback: ThreeFingerTapRecognizer.shared.callback)
  }

  @objc private func restartRecognizer() {
    touchDevices.restart(callback: ThreeFingerTapRecognizer.shared.callback)
  }

  private func observeWakeNotifications() {
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(handleWake),
      name: NSWorkspace.didWakeNotification,
      object: nil
    )
  }

  @objc private func handleWake() {
    restartRecognizer()
  }

  private func ensureAccessibilityPrompt() {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    let trusted = AXIsProcessTrustedWithOptions(options)
    Log.info("accessibility trusted: \(trusted)")
  }

  @objc private func openAccessibilitySettings() {
    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
      NSWorkspace.shared.open(url)
    }
  }

  @objc private func sendTestMiddleClick() {
    Log.info("manual test requested from menu")
    ThreeFingerTapRecognizer.shared.postMiddleClickForTesting()
  }

  @objc private func quit() {
    NSApp.terminate(nil)
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.setActivationPolicy(.accessory)
app.delegate = delegate
app.run()
