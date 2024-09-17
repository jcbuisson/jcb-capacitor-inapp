import Foundation
import Capacitor
import StoreKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(InAppPurchasePlugin)
public class InAppPurchasePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "InAppPurchasePlugin"
    public let jsName = "InAppPurchase"

    public var storedValue: Any = [] // JCB

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "buyProduct", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPurchases", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "test", returnType: CAPPluginReturnPromise),
    ]
    private let implementation = InAppPurchase()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    @available(iOS 15.0, *)
    @objc func buyProduct(_ call: CAPPluginCall) {
        let productId = call.getString("productId") ?? ""
        Task {
            do {
                let products = try await Product.products(for: [productId])
                if (products.count == 1) {
                    let product = products.first!
                    print("prod", product.description, product.price, product)

                    let result = try await product.purchase()

                    // switch result {
                    // case let .success(.verified(transaction)):
                    //     // Successful purhcase
                    //     print("Purchase successful for product: \(transaction.productID)")
                    //     await transaction.finish()
                    // case let .success(.unverified(_, error)):
                    //     // Successful purchase but transaction/receipt can't be verified. Could be a jailbroken phone
                    //     print("Unverified purchase. Might be jailbroken. Error: \(error)")
                    //     break
                    // case .pending:
                    //     // Transaction waiting on SCA (Strong Customer Authentication) or approval from Ask to Buy
                    //     break
                    // case .userCancelled:
                    //     print("User Cancelled!")
                    //     break
                    // @unknown default:
                    //     print("Failed to purchase the product!")
                    //     break
                    // }

                    switch result {
                    case .success(let verification):
                        // Check if the transaction is verified
                        switch verification {
                        case .verified(let transaction):
                            print("Purchase successful for product: \(transaction.productID)")
                            
                            // Store product ID in purchased list
                            // purchasedProductIDs.insert(transaction.productID)
                            
                            // Finish the transaction
                            await transaction.finish()
                            
                        case .unverified(_, let error):
                            print("Unverified transaction: \(error.localizedDescription)")
                        }
                        
                    case .userCancelled:
                        print("User cancelled the purchase.")
                        
                    case .pending:
                        print("Purchase is pending.")
                    }

                    call.resolve([
                        "productId": product.id,
                        "displayPrice": product.displayPrice,
                        "description": product.description,
                    ])
                } else {
                    call.reject("NotFound", "product not found")
                }
            } catch {
                call.reject("Failed", error.localizedDescription)
            }
        }
    }

    @available(iOS 15.0, *)
    @objc func getPurchases(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        Task {
            var purchasedProductIDs: Set<String> = []
            do {
                for await verificationResult in Transaction.currentEntitlements {
                    switch verificationResult {
                    case .verified(let transaction):
                        // Check the type of product for the transaction and provide access to the content as appropriate.
                        print("Restored product: \(transaction.productID)")
                        purchasedProductIDs.insert(transaction.productID)
                    case .unverified(let unverifiedTransaction, let verificationError):
                        // Handle unverified transactions based on your business model.
                        print("unverified")
                    }
                }
                let arrayOfStrings = Array(purchasedProductIDs)
                let jsonData = try JSONEncoder().encode(arrayOfStrings)
                let jsonString = String(data: jsonData, encoding: .utf8)
                call.resolve([
                    "value": jsonString
                ])
            } catch {
                call.reject("Failed currentEntitlements", error.localizedDescription)
            }
        }
    }

    @objc func test(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

}
