//
//  ContentView.swift
//  FocusTimer
//
//  Created by Lou Zell on 6/15/23.
//

import SwiftUI

struct ContentView: View {
    @State private var location: CGPoint = CGPoint(x: 30, y: 25)

    // Simplified from: https://sarunw.com/posts/move-view-around-with-drag-gesture-in-swiftui/
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                self.location = value.location
            }
    }

    @StateObject private var time = Time()
    var body: some View {
        Text(String(self.time.seconds))
        .padding()
        .background(.green)
        .position(location)
        .gesture(dragGesture)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

    }
}
