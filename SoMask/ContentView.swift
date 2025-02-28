//
//  ContentView.swift
//  SoMask
//
//  Created by soso on 2025/2/28.
//

import SwiftUI
import SwiftData

struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
    @StateObject var metaMaskRepo = MetaMaskRepo.init()

    var body: some View {
        VStack {
            Text("SoMask")
                .font(.title)
            Text(metaMaskRepo.metamaskSDK.account)
                .fontWeight(.bold)
            Button {
                Task {
                     await metaMaskRepo.connectToDapp()
                 }
            } label: {
                Text("Connect to metamask")
                    .frame(width: 300, height: 50)
            }
        }
        .onOpenURL { url in
              handleURL(url)
          }
        .padding()
    }
    
    private func handleURL(_ url: URL) {
        if URLComponents(url: url, resolvingAgainstBaseURL: true)?.host == "mmsdk" {
            metaMaskRepo.metamaskSDK.handleUrl(url)
        } else {
            // handle other deeplinks
        }
    }

}

#Preview {
    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
}
