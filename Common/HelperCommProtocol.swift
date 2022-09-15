import Foundation

@objc public protocol BTHelperCommProtocol {
    func queryPowerAdapterEnabled(reply: @escaping ((Bool) -> Void)) -> Void
    func enablePowerAdapter() -> Void
    func disablePowerAdapter() -> Void
    func chargeToMaximum() -> Void
    func chargeToFull() -> Void
    func setSettings(settings: [String: AnyObject]) -> Void
    func removeHelperFiles() -> Void
}
