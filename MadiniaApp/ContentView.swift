//
//  ContentView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "graduationcap.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Bienvenue sur Madinia")
                .font(.title)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
