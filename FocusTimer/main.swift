#!/usr/bin/env swift
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
///     curl -O https://www.louzell.com/programs/focus
///
/// Make it executable:
///
///     chmod +x focus
///
/// Run it:
///
///     focus
///     :: Use ctrl+c to quit

import AppKit
import SwiftUI

class FocusTimerAppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        /* Configure window */
        let window = NSWindow(contentRect: NSScreen.main!.frame,
                              styleMask: [.borderless],
                              backing: .buffered,
                              defer: true)
        window.backgroundColor = .clear
        window.level = NSWindow.Level.statusBar

        /* Configure hosting controller */
        let hostingController = NSHostingController(rootView: ContentView())
        hostingController.view.wantsLayer = true
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        /* Create full screen transparent overlay */
        let overlay = NSView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.wantsLayer = true
        overlay.layer!.backgroundColor = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0).cgColor

        /* Create view hierarchy */
        window.contentView!.addSubview(overlay)
        overlay.addSubview(hostingController.view)

        /* Apply autolayout constraints */
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            overlay.leftAnchor.constraint(equalTo: window.contentView!.leftAnchor),
            overlay.rightAnchor.constraint(equalTo: window.contentView!.rightAnchor),
            overlay.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 5),
            hostingController.view.bottomAnchor.constraint(equalTo: overlay.bottomAnchor, constant: -5),
        ])

        window.makeKeyAndOrderFront(nil)
    }
}



let monitorForSigInt = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
monitorForSigInt.setEventHandler(handler: {
    exit(0)
})
monitorForSigInt.resume()

let appDelegate = FocusTimerAppDelegate()
NSApplication.shared.delegate = appDelegate
NSApplication.shared.run()
