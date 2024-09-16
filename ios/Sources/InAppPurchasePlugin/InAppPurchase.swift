import Foundation
import StoreKit


@objc public class InAppPurchase: NSObject {

    @objc public func echo(_ value: String) -> String {

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

        print(value)
        print("qsd")
        return value
    }

}
