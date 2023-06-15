#! /usr/bin/env swift
///
///
/// Creates a visual overlay of a timer in the bottom left corner.
/// The timer counts down from 20 minutes in seconds.
///
/// Usage
/// -----
///
/// Save this program anywhere in your path, and make it executable.
///
/// For example, in Term:
///
///     cd /usr/local/bin
///     curl -O https://www.louzell.com/programs/FocusTimer
///
/// Make it executable:
///
///     chmod +x FocusTimer
///
/// Run it:
///
///     FocusTimer
///     :: Use ctrl+c to quit

import AppKit
import Dispatch

class ScreenMaskAppDelegate: NSObject, NSApplicationDelegate {
    /// A clear window applied over all others; one that does not intercept taps or clicks
    private var window: NSWindow!

    /// The timer that counts down and calls -decrement each second
    private var timer: DispatchSourceTimer!

    /// The text field holding the remaining time
    private weak var textField: NSTextField!

    /// The gray background view that holds `textField`
    private weak var overlayView: NSView!

    /// Number of seconds to count down from
    private var seconds = 60 * 20 {
        didSet {
            self.textField.stringValue = "\(self.seconds)"
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.window = createWindow()
        let textField = createTextField(withContent: String(self.seconds))
        let overlayView = createOverlayView()
        overlayView.addSubview(textField)
        self.window.contentView!.addSubview(overlayView)
        self.textField = textField
        self.overlayView = overlayView
        self.timer = createTimer(calling: self.decrement)
        self.timer.resume()
        self.applyAutolayoutConstraints()
        self.window.orderFront(nil)
    }

    private func decrement() {
        self.seconds -= 1
    }

    private func applyAutolayoutConstraints() {
        let margin: CGFloat = 5
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: margin),
            textField.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: margin),
            textField.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -margin),
            textField.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -margin),
        ])

        NSLayoutConstraint.activate([
            overlayView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
        ])
    }
}


private func createWindow() -> NSWindow {
    let window = NSWindow(contentRect: NSScreen.main!.frame,
                          styleMask: [.borderless],
                          backing: .buffered,
                          defer: true)
    window.backgroundColor = .clear
    window.level = .floating
    window.ignoresMouseEvents = true
    return window
}

private func createTextField(withContent content: String) -> NSTextField {
    let textfield = NSTextField(labelWithString: content)
    textfield.translatesAutoresizingMaskIntoConstraints = false
    textfield.textColor = .red
    return textfield
}

private func createOverlayView() -> NSView {
    let view = NSView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.wantsLayer = true
    view.layer!.backgroundColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
    view.layer!.cornerRadius = 5
    return view
}

private func createTimer(calling theCall: @escaping () -> Void) -> DispatchSourceTimer {
    let queue = DispatchQueue(label: "lzell")
    let timer = DispatchSource.makeTimerSource(queue: queue)
    timer.setEventHandler {
        dispatchPrecondition(condition: .onQueue(queue))
        DispatchQueue.main.async {
            theCall()
        }
    }
    timer.schedule(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1),
                   repeating: .seconds(1),
                   leeway: .milliseconds(1))
    return timer
}


let monitorForSigInt = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
monitorForSigInt.setEventHandler(handler: {
    exit(0)
})
monitorForSigInt.resume()

let appDelegate = ScreenMaskAppDelegate()
NSApplication.shared.delegate = appDelegate
NSApplication.shared.run()
