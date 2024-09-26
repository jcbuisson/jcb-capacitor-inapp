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
        // CAPPluginMethod(name: "getPurchases", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "checkSubscription", returnType: CAPPluginReturnPromise),
    ]

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        print(value)
        print("eee")
        call.resolve([
            "value": value
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
                    var revocationDate: Date? = nil
                    var expirationDate: Date? = nil
                    var status: String? = nil

                    switch result {
                    case .success(let verification):
                        // Check if the transaction is verified
                        switch verification {
                        case .verified(let transaction):
                            print("Purchase successful for product: \(transaction.productID)")

                            if transaction.revocationDate != nil {
                                // subscription canceled or refunded by Apple
                                print("Subscription was revoked on \(String(describing: transaction.revocationDate)).")
                                status = "revoked"
                            } else if let expirationDate = transaction.expirationDate {
                                if expirationDate < Date() {
                                    print("Subscription has expired on \(expirationDate).")
                                    status = "expired"
                                } else {
                                    print("Subscription is still active, expires on \(expirationDate).")
                                    status = "active"
                                }
                            } else {
                                print("No expiration date. The subscription is active with no known expiration.")
                                status = "active"
                            }

                            // Finish the transaction
                            await transaction.finish()
                            
                        case .unverified(_, let error):
                            print("Unverified transaction: \(error.localizedDescription)")
                            status = "unverified"
                        }
                        
                    case .userCancelled:
                        print("User canceled the purchase.")
                        status = "canceled"
                        
                    case .pending:
                        print("Purchase is pending.")
                        status = "pending"
                    }

                    call.resolve([
                        "productId": productId,
                        "status": status,
                    ])
                } else {
                    call.reject("NotFound", "product not found")
                }
            } catch {
                call.reject("Failed", error.localizedDescription)
            }
        }
    }

    // @available(iOS 15.0, *)
    // @objc func getPurchases(_ call: CAPPluginCall) {
    //     Task {
    //         var activeProductIDs: Set<String> = []
    //         do {
    //             for await verificationResult in Transaction.currentEntitlements {
    //                 switch verificationResult {
    //                 case .verified(let transaction):
    //                     if transaction.revocationDate != nil {
    //                         // subscription canceled or refunded by Apple
    //                         print("Subscription was revoked on \(String(describing: transaction.revocationDate)).")
    //                     } else if let expirationDate = transaction.expirationDate {
    //                         if expirationDate < Date() {
    //                             print("Subscription has expired on \(expirationDate).")
    //                         } else {
    //                             print("Subscription is still active, expires on \(expirationDate).")
    //                             activeProductIDs.insert(transaction.productID)
    //                         }
    //                     } else {
    //                         print("No expiration date. The subscription is active with no known expiration.")
    //                     }

    //                 case .unverified(let unverifiedTransaction, let verificationError):
    //                     // jailbroken phone?
    //                     print("unverified")
    //                 }
    //             }

    //             let arrayOfStrings = Array(activeProductIDs)
    //             let jsonData = try JSONEncoder().encode(arrayOfStrings)
    //             let jsonString = String(data: jsonData, encoding: .utf8)
    //             call.resolve([
    //                 "value": jsonString
    //             ])
    //         } catch {
    //             call.reject("Failed currentEntitlements", error.localizedDescription)
    //         }
    //     }
    // }


    @available(iOS 15.0, *)
    @objc func checkSubscription(_ call: CAPPluginCall) {
        Task {
            var productId: String? = nil
            var revocationDate: Date? = nil
            var expirationDate: Date? = nil
                    var status: String? = nil
            do {
                for await verificationResult in Transaction.currentEntitlements {
                    switch verificationResult {
                    case .verified(let transaction):
                        productId = transaction.productID
                        if transaction.revocationDate != nil {
                            // subscription canceled or refunded by Apple
                            print("Subscription was revoked on \(String(describing: transaction.revocationDate)).")
                            status = "canceled"
                        } else if let expirationDate = transaction.expirationDate {
                            if expirationDate < Date() {
                                print("Subscription has expired on \(expirationDate).")
                                status = "expired"
                            } else {
                                print("Subscription is still active, expires on \(expirationDate).")
                                status = "active"
                            }
                        } else {
                            print("No expiration date. The subscription is active with no known expiration.")
                            status = "active"
                        }

                    case .unverified(let unverifiedTransaction, let verificationError):
                        // jailbroken phone?
                        print("unverified")
                        status = "unverified"
                    }
                }

                call.resolve([
                    "productId": productId,
                    "status": status,
                ])
            } catch {
                call.reject("Failed currentEntitlements", error.localizedDescription)
            }
        }
    }

}
