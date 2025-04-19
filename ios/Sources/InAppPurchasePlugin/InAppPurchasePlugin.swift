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
        CAPPluginMethod(name: "getSubscriptionProductInfo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "buySubscription", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "checkSubscription", returnType: CAPPluginReturnPromise),
    ]

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        print(value)
        call.resolve([
            "value": value
        ])
    }

    @available(iOS 15.0, *)
    @objc func getSubscriptionProductInfo(_ call: CAPPluginCall) {
        let productId = call.getString("productId") ?? ""
        Task {
            do {
                let products = try await Product.products(for: [productId])
                if (products.count == 1) {
                    let product = products.first!
                    print(product.displayName)
                    print(product.description)
                    print(product.displayPrice)
                    let period: String
                    switch (product.subscription?.subscriptionPeriod.unit) {
                        case .month:
                            period = "mois"
                        case .year:
                            period = "an"
                        default:
                            period = "--"
                    }
                    print(period)
                    call.resolve([
                        "productId": productId,
                        "platform": "ios",
                        "name": product.displayName,
                        "description": product.description,
                        "price": product.displayPrice,
                        "period": period,
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
    @objc func buySubscription(_ call: CAPPluginCall) {
        let productId = call.getString("productId") ?? ""
        Task {
            do {
                let products = try await Product.products(for: [productId])
                if (products.count == 1) {
                    let product = products.first!
                    print("prod", product.description, product.price, product)

                    // PURCHASE
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
                        "platform": "ios",
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
                        print("Subscription is unverified")
                        status = "unverified"
                    }
                }

                call.resolve([
                    "productId": productId,
                    "platform": "ios",
                    "status": status,
                ])
            } catch {
                call.reject("Failed", error.localizedDescription)
            }
        }
    }

}
