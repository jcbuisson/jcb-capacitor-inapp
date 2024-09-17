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

}
