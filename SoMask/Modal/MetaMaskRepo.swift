//
//  MetaMaskRepo.swift
//  SoMask
//
//  Created by soso on 2025/2/28.
//

import Combine
import SwiftUI
import metamask_ios_sdk

import Foundation
import BigInt

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
    @Published var balance = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        let appMetadata = AppMetadata(name: "SoMask", url: "https://SoMask.com")

        metamaskSDK = MetaMaskSDK.shared(
            appMetadata,
            transport: .deeplinking(dappScheme: "SoMask"),
            sdkOptions: SDKOptions(
                infuraAPIKey: "37c4affd9b39b901",
                readonlyRPCMap: [
                    "0x1": "https://mainnet.infura.io/v3/37c4affd9b39416c84029afdfaaab901"
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
    
    func getAccountBalance() async {
        let requestResult = await metamaskSDK.getEthBalance(address: metamaskSDK.account, block: "latest")
        
        switch requestResult {
        case let .success(value):
            balance = weiToEthString(hexWei:value, decimalPlaces: 18) ?? "0"
            print("Get Balance result: \(requestResult)")
        case let .failure(error):
            print("Get Balance error: \(error.localizedDescription)")
        }
    }
    
    func weiToEthString(hexWei: String, decimalPlaces: Int = 18) -> String? {
        // Remove the "0x" prefix if it exists
        let cleanedHexWei = hexWei.hasPrefix("0x") ? String(hexWei.dropFirst(2)) : hexWei
        
        // Convert the hexadecimal string to BigInt
        guard let wei = BigInt(cleanedHexWei, radix: 16) else {
            return nil
        }
        
        // Convert wei to ETH by dividing by 10^18
        let eth = Decimal(string: wei.description)! / pow(10, 18)
        
        // Format the ETH value as a string with the specified number of decimal places
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimalPlaces
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false // Disable thousands separator
        
        return formatter.string(from: eth as NSDecimalNumber)
    }
}
