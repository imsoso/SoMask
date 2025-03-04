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
    @ObservedObject var metaMaskRepo = MetaMaskRepo()
    @State private var status = "Not Connected"
    @State private var showProgressView = false
    @State private var isConnectWith = false
    @State private var isConnectAndSign = false
    
    var body: some View {
        NavigationView {
            
            ZStack{
                VStack(alignment:.leading, spacing: 32){
                    Section {
                        Group {
                            
                            Text("Status: \(metaMaskRepo.metamaskSDK.connected)")
                                .fontWeight(.bold)
                            Text("Chain ID: \(metaMaskRepo.metamaskSDK.chainId)")
                                .fontWeight(.bold)
                            Text("Account: \(metaMaskRepo.metamaskSDK.account)")
                                .fontWeight(.bold)
                        }
                    }
                    
                    if !metaMaskRepo.metamaskSDK.account.isEmpty {
                        Section {
                            Group {
                                //                            NavigationLink("Sign") {
                                //                                SignView().environmentObject(metaMaskSDK)
                                //                            }
                                
                                //                            NavigationLink("Chained signing") {
                                //                                SignView(isChainedSigning: true).environmentObject(metaMaskSDK)
                                //                            }
                                
                                //                            NavigationLink("Transact") {
                                //                                TransactionView().environmentObject(metaMaskSDK)
                                //                            }
                                if !metaMaskRepo.metamaskSDK.account.isEmpty {   
                                    NavigationLink("Switch chain") {
                                        SwitchChainView().environmentObject(metaMaskRepo.metamaskSDK)
                                    }
                                }
                                NavigationLink("Read-only RPCs") {
                                    ReadOnlyCallsView().environmentObject(metaMaskRepo.metamaskSDK)
                                }
                            }
                        }
                    }
                    if metaMaskRepo.metamaskSDK.account.isEmpty {
                        Section {
                            Button {
                                isConnectWith = true
                            } label: {
                                Text("Connect With Request")
                                    .modifier(TextButton())
                                    .frame(maxWidth: .infinity, maxHeight: 32)
                            }
                            .sheet(isPresented: $isConnectWith, onDismiss: {
                                isConnectWith = false
                            }) {
                                //                            TransactionView(isConnectWith: true)
                                //                                .environmentObject(metaMaskSDK)
                            }
                            .modifier(ButtonStyle())
                            
                            Button {
                                isConnectAndSign = true
                            } label: {
                                Text("Connect & Sign")
                                    .modifier(TextButton())
                                    .frame(maxWidth: .infinity, maxHeight: 32)
                            }
                            .sheet(isPresented: $isConnectAndSign, onDismiss: {
                                isConnectAndSign = false
                            }) {
                                //                            SignView(isConnectAndSign: true)
                                //                                .environmentObject(metaMaskSDK)
                            }
                            .modifier(ButtonStyle())
                            ZStack {
                                Button {
                                    Task {
                                        await metaMaskRepo.connectToDapp()
                                    }
                                } label: {
                                    Text("Connect to MetaMask")
                                        .modifier(TextButton())
                                        .frame(maxWidth: .infinity, maxHeight: 32)
                                }
                                .modifier(ButtonStyle())
                                
                                if showProgressView {
                                    ProgressView()
                                        .scaleEffect(1.5, anchor: .center)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                }
                            }
                            .alert(isPresented: $metaMaskRepo.showError) {
                                Alert(
                                    title: Text("Error"),
                                    message: Text(metaMaskRepo.errorMessage)
                                )
                            }
                        } footer: {
                            //                        Text(connectAndSignResult)
                            //                            .modifier(TextCaption())
                        }
                    }
                    if !metaMaskRepo.metamaskSDK.account.isEmpty {
                        Section {
                            Button {
                                metaMaskRepo.metamaskSDK.clearSession()
                            } label: {
                                Text("Clear Session")
                                    .modifier(TextButton())
                                    .frame(maxWidth: .infinity, maxHeight: 32)
                            }
                            .modifier(ButtonStyle())
                            
                            Button {
                                metaMaskRepo.metamaskSDK.disconnect()
                            } label: {
                                Text("Disconnect")
                                    .modifier(TextButton())
                                    .frame(maxWidth: .infinity, maxHeight: 32)
                            }
                            .modifier(ButtonStyle())
                        }
                    }
                    
                }
                .font(.body)
                .navigationTitle("SoMask")
                .onAppear {
                    showProgressView = false
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
