import Foundation
import StoreKit


@objc public class InAppPurchase: NSObject {

    @objc public func echo(_ value: String) -> String {
        print(value)
        print("eee")
        return value
    }

    @objc public func test(_ value: String) -> String {
        print(value)
        print("ttt")
        return value
    }

    @available(iOS 15.0, *)
    public func refreshPurchasedProducts() async {
        // Iterate through the user's purchased products.
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                // Check the type of product for the transaction and provide access to the content as appropriate.
                print("verified")
            case .unverified(let unverifiedTransaction, let verificationError):
                // Handle unverified transactions based on your business model.
                print("unverified")
            }
        }
    }

}
