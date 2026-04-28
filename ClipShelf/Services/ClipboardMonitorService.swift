import Foundation
import UIKit

protocol ClipboardMonitoring {
    func copyToClipboard(_ item: ClipboardItem, imageData: Data?)
}

final class ClipboardMonitorService: ClipboardMonitoring {
    func copyToClipboard(_ item: ClipboardItem, imageData: Data?) {
        switch item.kind {
        case .text:
            UIPasteboard.general.string = item.textContent
        case .image:
            guard
                let imageData,
                let image = UIImage(data: imageData)
            else {
                return
            }

            UIPasteboard.general.image = image
        }
    }
}
