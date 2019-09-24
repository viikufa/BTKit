import Foundation

public struct BTKitConnection {
    @discardableResult
    public func establish<T: AnyObject>(for observer: T, uuid: String, result: @escaping (T, BTConnectResult) -> Void) -> ObservationToken? {
        if BTKit.scanner.isConnected(uuid: uuid) {
            result(observer, .already)
            return nil
        } else {
            let connectToken = BTKit.scanner.connect(observer, uuid: uuid, connected: { (observer, error) in
                if let error = error {
                    result(observer, .failure(error))
                } else {
                    result(observer, .just)
                }
                
            }) { (observer, error) in
                if let error = error {
                    result(observer, .failure(error))
                } else {
                    result(observer, .disconnected)
                }
            }
            return connectToken
        }
    }
    
    @discardableResult
    public func drop<T:AnyObject>(for observer: T, uuid: String, result: @escaping (T, BTDisconnectResult) -> Void) -> ObservationToken? {
        if !BTKit.scanner.isConnected(uuid: uuid) {
            result(observer, .already)
            return nil
        } else {
            return BTKit.scanner.disconnect(observer, uuid: uuid, disconnected: { (observer, error) in
                if let error = error {
                    result(observer, .failure(error))
                } else {
                    result(observer, .just)
                }
            })
        }
    }
    
}
