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
    @StateObject var metaMaskRepo = MetaMaskRepo()
    @State private var status = "Not Connected"
    
    var body: some View {
        VStack(alignment:.leading, spacing: 32){
            Text("SoMask")
                .font(.title)
            Text("Status: \(metaMaskRepo.metamaskSDK.connected)")
                .fontWeight(.bold)
            Text("Chain ID: \(metaMaskRepo.metamaskSDK.chainId)")
                .fontWeight(.bold)
            Text("Account: \(metaMaskRepo.metamaskSDK.account)")
                .fontWeight(.bold)
            Button {
                Task {
                    await metaMaskRepo.connectToDapp()
                }
            } label: {
                Text("Connect to metamask")
                    .frame(width: 300, height: 50)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .Connection)) { notification in
            status = notification.userInfo?["value"] as? String ?? "Not Connected"
        }
        .onOpenURL { url in
              handleURL(url)
        }
        .padding()
    }
    
    
    func handleURL(_ url: URL) {
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
