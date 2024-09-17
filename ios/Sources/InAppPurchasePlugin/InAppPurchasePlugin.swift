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
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.buyProduct(value)
        ])
    }

    @available(iOS 15.0, *)
    @objc func test(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        Task {
            do {
                let products = try await Product.products(for: ["premium"])

                // Return the result to JavaScript using resolve
                // call.resolve([
                //     "data": products
                // ])
                if (products.count == 1) {
                    let product = products.first!
                    print("prod", product.description, product.price, product)
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
