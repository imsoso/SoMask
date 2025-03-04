//
//  TransactionView.swift
//  SoMask
//
//  Created by soso on 2025/3/4.
//

import SwiftUI
import Combine
import metamask_ios_sdk

@MainActor
struct TransactionView: View {
    @EnvironmentObject var metamaskSDK: MetaMaskSDK

    @State private var value = "1"
        
    @State var result: String = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var to = "0x0000000000000000000000000000000000000000"
    @State var isConnectWith: Bool = false
    @State private var sendTransactionTitle = "Send Transaction"
    @State private var connectWithSendTransactionTitle = "Connect & Send Transaction"

    @State private var showProgressView = false

    var body: some View {
        Form {
            Section {
                Text("From")
                    .modifier(TextCallout())
                TextField("Enter sender address", text: $metamaskSDK.account)
                    .modifier(TextCaption())
                    .frame(minHeight: 32)
                    .modifier(TextCurvature())
            }

            Section {
                Text("To")
                    .modifier(TextCallout())
                TextEditor(text: $to)
                    .modifier(TextCaption())
                    .frame(minHeight: 32)
                    .modifier(TextCurvature())
            }

            Section {
                Text("Value")
                    .modifier(TextCallout())
                TextField("Value", text: $value)
                    .modifier(TextCaption())
                    .frame(minHeight: 32)
                    .modifier(TextCurvature())
            }

            Section {
                Text("Result")
                    .modifier(TextCallout())
                TextEditor(text: $result)
                    .modifier(TextCaption())
                    .frame(minHeight: 40)
                    .modifier(TextCurvature())
            }

            Section {
                ZStack {
                    Button {
                        Task {
                            await sendTransaction()
                        }
                    } label: {
                        Text(isConnectWith ? connectWithSendTransactionTitle : sendTransactionTitle)
                            .modifier(TextButton())
                            .frame(maxWidth: .infinity, maxHeight: 32)
                    }
                    .alert(isPresented: $showError) {
                        Alert(
                            title: Text("Error"),
                            message: Text(errorMessage)
                        )
                    }
                    .modifier(ButtonStyle())

                    if showProgressView {
                        ProgressView()
                            .scaleEffect(1.5, anchor: .center)
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    }
                }
            }
        }
        .background(Color.blue.grayscale(0.5))
    }

    // Convert ETH to Wei (hex string)
    func convertEthToWeiHex(eth: String) -> String? {
        // Ensure the input is a valid decimal number
        guard let ethValue = Decimal(string: eth) else {
            return nil
        }
        
        // Define the conversion factor: 1 ETH = 10^18 Wei
        let weiPerEth = Decimal(sign: .plus, exponent: 18, significand: 1)
        
        // Perform the conversion
        let weiValue = ethValue * weiPerEth
        
        // Convert Decimal to NSDecimalNumber
        let weiNSDecimal = weiValue as NSDecimalNumber
        
        // Convert NSDecimalNumber to a hexadecimal string
        let weiHex = String(format: "0x%02llx", weiNSDecimal.uint64Value)
        
        return weiHex
    }
    
    func sendTransaction() async {
        print("sending value: \(value)")

        print("sending eth : \(convertEthToWeiHex(eth:value) )" )
        let transaction = Transaction(
            to: to,
            from: metamaskSDK.account,
            value: convertEthToWeiHex(eth:value) ?? "0"
        )

        let parameters: [Transaction] = [transaction]

        let transactionRequest = EthereumRequest(
            method: .ethSendTransaction,
            params: parameters // eth_sendTransaction rpc call expects an array parameters object
        )

        showProgressView = true

        let transactionResult = isConnectWith
        ? await metamaskSDK.connectWith(transactionRequest)
        : await metamaskSDK.sendTransaction(from: metamaskSDK.account, to: to, value: convertEthToWeiHex(eth:value) ?? "0")

        showProgressView = false

        switch transactionResult {
        case let .success(value):
            result = value
        case let .failure(error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

struct Transaction: CodableData {
    let to: String
    let from: String
    let value: String
    let data: String?

    init(to: String, from: String, value: String, data: String? = nil) {
        self.to = to
        self.from = from
        self.value = value
        self.data = data
    }

    func socketRepresentation() -> NetworkData {
        [
            "to": to,
            "from": from,
            "value": value,
            "data": data
        ]
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
