import Foundation
import StoreKit


@objc public class InAppPurchase: NSObject {

    @objc public func echo(_ value: String) -> String {
        print(value)
        print("qsd")
        return value
    }

    @objc public func fetchProducts(_ value: String) -> String {

        async {
            do {
                if #available(iOS 15.0, *) {
                    let products = try await Product.products(for: ["premium"])
                    print("products")
                    print(products)
                } else {
                    // Fallback on earlier versions
                    print("needs iOS15")
                }
            }
            catch {
                print(error)
            }
        }
        return value
    }

    public func refreshPurchasedProducts() async {
        // Iterate through the user's purchased products.
        if #available(iOS 15.0, *) {
            for await verificationResult in Transaction.currentEntitlements {
                switch verificationResult {
                case .verified(let transaction):
                    // Check the type of product for the transaction
                    // and provide access to the content as appropriate.
                    print("verified")
                case .unverified(let unverifiedTransaction, let verificationError):
                    // Handle unverified transactions based on your
                    // business model.
                    print("unverified")
                }
            }
        } else {
            // Fallback on earlier versions
            print("needs iOS15")
        }
    }

}
