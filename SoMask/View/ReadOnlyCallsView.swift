//
//  ReadOnlyCallsView.swift
//  SoMask
//
//  Created by soso on 2025/3/3.
//


import Foundation
import SwiftUI
import Combine
import metamask_ios_sdk

@MainActor
struct ReadOnlyCallsView: View {
    @EnvironmentObject var metaMaskRepo: MetaMaskRepo
//    @ObservedObject var metaMaskRepo = MetaMaskRepo()

    @State private var showProgressView = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    Spacer()

                    VStack {
                        Text("Balance: \(metaMaskRepo.balance)")
                            .fontWeight(.bold)
                        Button {
                            Task {
                                showProgressView = true
                                await metaMaskRepo.getAccountBalance()
                                showProgressView = false
                            }
                        } label: {
                            Text("Get account balance")
                                .frame(width: 300, height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    VStack {
                        Text("Gas price: \(metaMaskRepo.gasPrice)")
                            .fontWeight(.bold)
                        Button {
                            Task {
                                showProgressView = true
                                await metaMaskRepo.getGasPrice()
                                showProgressView = false
                            }
                        } label: {
                            Text("Get Gas Price")
                                .frame(width: 300, height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    VStack {
                        Text("Client Version: \(metaMaskRepo.web3ClientVersion)")
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Button {
                            Task {
                                showProgressView = true
                                await metaMaskRepo.getWeb3ClientVersion()
                                showProgressView = false
                            }
                        } label: {
                            Text("Get Web3 Client Version")
                                .frame(width: 300, height: 50)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()

                }
                .padding(.horizontal)

                if showProgressView {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage)
                )
            }
            .onAppear {
                showProgressView = false
            }
        }
        .navigationTitle("Read-Only Calls")
    }

}

struct ReadOnlyCalls_Previews: PreviewProvider {
    static var previews: some View {
        ReadOnlyCallsView()
    }
}
