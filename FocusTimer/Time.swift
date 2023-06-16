//
//  Time.swift
//  FocusTimer
//
//  Created by Lou Zell on 6/15/23.
//

import Foundation
import SwiftUI

// Migrate once MacOS 14 lands.
// https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro

class Time: ObservableObject {
    @Published var seconds = 20 * 60

    /// The timer that counts down and calls -decrement each second
    private var timer: DispatchSourceTimer!

    init() {
        self.timer = createTimer() { [weak self] in
            self?.seconds -= 1
        }
        self.timer.resume()
    }
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

