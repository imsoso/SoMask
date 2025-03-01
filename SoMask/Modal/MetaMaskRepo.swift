//
//  MetaMaskRepo.swift
//  SoMask
//
//  Created by soso on 2025/2/28.
//

import Combine
import SwiftUI
import metamask_ios_sdk

extension Notification.Name {
    static let Connection = Notification.Name("Connection")
}

@MainActor
class MetaMaskRepo: ObservableObject {
    @Published var connectionStatus = "Not Connected" {
        didSet {
            NotificationCenter.default.post(
                name: .Connection, object: nil, userInfo: ["value": connectionStatus])
        }
    }
    @Published  var metamaskSDK: MetaMaskSDK

    private var cancellables = Set<AnyCancellable>()

    init() {
        let appMetadata = AppMetadata(name: "SoMask", url: "https://SoMask.com")

        metamaskSDK = MetaMaskSDK.shared(
            appMetadata,
            transport: .deeplinking(dappScheme: "SoMask"),
            sdkOptions: SDKOptions(
                infuraAPIKey: "37c4affd9b39b901",
                readonlyRPCMap: [
                    "0x1": "https://www.testrpc.com"
                ])  // for read-only RPC calls
        )

        observeConnectionStatus()
    }

    func connectToDapp() async {
        let connectResult = await metamaskSDK.connect()
        
        switch connectResult {
        case .success(let result):
            print("Connection result: \(result)")
        case .failure(let error):
            print("Connection error: \(error.localizedDescription)")
        }
    }

    private func observeConnectionStatus() {
        metamaskSDK.$connected
            .sink {
                [weak self] isConnected in
                self?.connectionStatus = isConnected ? "Connected" : "Diskconnected"
            }
            .store(in: &cancellables)
    }
}
