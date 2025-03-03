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
    @State private var showProgressView = false

    var body: some View {
        ZStack{
            VStack(alignment:.leading, spacing: 32){
                Text("SoMask")
                    .font(.title)
                Text("Status: \(metaMaskRepo.metamaskSDK.connected)")
                    .fontWeight(.bold)
                Text("Chain ID: \(metaMaskRepo.metamaskSDK.chainId)")
                    .fontWeight(.bold)
                Text("Account: \(metaMaskRepo.metamaskSDK.account)")
                    .fontWeight(.bold)
                VStack {
                    Button {
                        Task {
                            await metaMaskRepo.connectToDapp()
                        }
                    } label: {
                        Text("Connect to metamask")
                            .frame(width: 300, height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    Text("Balance: \(metaMaskRepo.balance)")
                        .fontWeight(.bold)
                    Button {
                        Task {
                            await metaMaskRepo.getAccountBalance()
                        }
                    } label: {
                        Text("Get account balance")
                            .frame(width: 300, height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            }
            if showProgressView {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 120, height: 120)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .Connection)) { notification in
            status = notification.userInfo?["value"] as? String ?? "Not Connected"
        }
        .onOpenURL { url in
              handleURL(url)
        }
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
