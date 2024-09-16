import Foundation
import StoreKit


@objc public class InAppPurchase: NSObject {

    public var myProduct: Any?

    @objc public func echo(_ value: String) -> String {
        print(value)
        print("qsd")
        return value
    }

    @available(iOS 15.0, *)
    @objc public func fetchProducts(_ value: String) -> String {
        async {
            do {
                myProduct = try await Product.products(for: ["premium"])
                print("products")
                print(myProduct)
            }
            catch {
                print(error)
            }
        }
        return "wxc"
    }


    @objc public func test(_ value: String) -> String {
        print(myProduct)
        return value
    }




    // public func buyProduct(_ product: Product) -> String {
    //     async {
    //         if #available(iOS 15.0, *) {
    //             do {
    //                 let result = try await product.purchase()
                    
    //                 switch result {
    //                 case let .success(.verified(transaction)):
    //                     // Successful purhcase
    //                     await transaction.finish()
    //                 case let .success(.unverified(_, error)):
    //                     // Successful purchase but transaction/receipt can't be verified
    //                     // Could be a jailbroken phone
    //                     print("Unverified purchase. Might be jailbroken. Error: \(error)")
    //                     break
    //                 case .pending:
    //                     // Transaction waiting on SCA (Strong Customer Authentication) or
    //                     // approval from Ask to Buy
    //                     break
    //                 case .userCancelled:
    //                     // ^^^
    //                     print("User Cancelled!")
    //                     break
    //                 @unknown default:
    //                     print("Failed to purchase the product!")
    //                     break
    //                 }
    //             } catch {
    //                 print("Failed to purchase the product!")
    //             }
    //         }
    //     } else {
    //         // Fallback on earlier versions
    //         print("needs iOS15")
    //     }
    //     return "buy"
    // }

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
