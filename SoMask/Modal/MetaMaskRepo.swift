//
//  MetaMaskRepo.swift
//  SoMask
//
//  Created by soso on 2025/2/28.
//

import SwiftUI
import metamask_ios_sdk

class MetaMaskRepo: ObservableObject {
    @ObservedObject var ethereumShare = MetaMaskSDK.sharedInstance!
    
    func connectToDapp() async {
        let appMetadata = AppMetadata(name: "Dub Dapp", url: "https://dubdapp.com")

        
        @ObservedObject var metamaskSDK = MetaMaskSDK.shared(
            appMetadata,
            transport: .deeplinking(dappScheme: "dubdapp"),
            sdkOptions: SDKOptions(infuraAPIKey: "your-api-key", readonlyRPCMap: ["0x1": "hptts://www.testrpc.com"]) // for read-only RPC calls
        )
        
        let connectResult = await metamaskSDK.connect()
        _ = await metamaskSDK.getChainId()
        
        // Create parameters
        let selectedAddress = metamaskSDK.account
        
        // Make request
        _ = await metamaskSDK.getEthBalance(address: selectedAddress, block: "latest")
    }
}
