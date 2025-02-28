//
//  MetaMaskRepo.swift
//  SoMask
//
//  Created by soso on 2025/2/28.
//

import SwiftUI
import metamask_ios_sdk

class MetaMaskRepo: ObservableObject {
    
    @ObservedObject var metamaskSDK: MetaMaskSDK
    
    init() {
        let appMetadata = AppMetadata(name: "SoMask", url: "https://dubdapp.com")
        
        metamaskSDK = MetaMaskSDK.shared(
            appMetadata,
            transport: .deeplinking(dappScheme: "SoMask"),
            sdkOptions: SDKOptions(infuraAPIKey: "c4affd9b39416c84029afdf901", readonlyRPCMap: ["0x1": "https://mainnet.infura.io/v3/37c4affd9b39416c84029afdfaaab901"]) // for read-only RPC calls
        )
        
    }
    
    func connectToDapp() async {

        let connectResult = await metamaskSDK.connect()
        _ = await metamaskSDK.getChainId()
        
        // Create parameters
        let selectedAddress = metamaskSDK.account
        
        // Make request
        _ = await metamaskSDK.getEthBalance(address: selectedAddress, block: "latest")
    }
}
