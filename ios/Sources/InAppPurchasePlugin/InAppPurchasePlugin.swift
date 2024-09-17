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

    public var storedValue: Any = []

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "buyProduct", returnType: CAPPluginReturnPromise),
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
        call.resolve([
            "value": implementation.buyProduct(productId)
        ])
    }

    @available(iOS 15.0, *)
    @objc func test(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        Task {
            do {
                let products = try await Product.products(for: ["premium"])
                if (products.count == 1) {
                    let product = products.first!
                    print("prod", product.description, product.price, product)

                    let result = try await product.purchase()
                    switch result {
                    case let .success(.verified(transaction)):
                        // Successful purhcase
                        await transaction.finish()
                    case let .success(.unverified(_, error)):
                        // Successful purchase but transaction/receipt can't be verified
                        // Could be a jailbroken phone
                        print("Unverified purchase. Might be jailbroken. Error: \(error)")
                        break
                    case .pending:
                        // Transaction waiting on SCA (Strong Customer Authentication) or
                        // approval from Ask to Buy
                        break
                    case .userCancelled:
                        // ^^^
                        print("User Cancelled!")
                        break
                    @unknown default:
                        print("Failed to purchase the product!")
                        break
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
}
