@objc(PopupMenu)
class PopupMenu: NSObject {
    
    @objc
    func showPopup(_ options: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
        
        DispatchQueue.main.async {
            var isDark = false
            if #available(iOS 12.0, *) {
                isDark = UIScreen.main.traitCollection.userInterfaceStyle == .dark
            }
            if let theme = options["theme"] as? String {
                isDark = theme == "dark"
            }
            
            let manager = PopMenuManager.default
            manager.actions.removeAll()
            let buttons = options["buttons"] as! [[String: Any]]
            for (index, button) in buttons.enumerated() {
                var icon: UIImage?
                if let i = button["icon"] as? String,
                let url = URL(string: i),
                let data = try? Data(contentsOf: url) {
                    icon = UIImage(data: data)
                }
                let color = RCTConvert.uiColor(button["tint"] as? NSNumber)
                manager.actions.append(
                    PopMenuDefaultAction(
                        title: button["text"] as? String,
                        image: icon,
                        color: color,
                        didSelect: { _ in callback([index])
                }))
            }
            
            let gravity = options["gravity"] as? String == "top"
            let tint: UIColor = isDark ? .white : .black
            manager.popMenuAppearance.popMenuBackgroundStyle = .none()
            manager.popMenuAppearance.popMenuColor.backgroundColor = .solid(fill: isDark ? .black : .white)
            manager.popMenuAppearance.rightIcon = (options["isIconsFromRight"] as? Bool) == true
            manager.popMenuAppearance.popMenuCornerRadius = (options["cornerRadius"] as? Double) ?? 20
            manager.popMenuAppearance.popMenuGravityBottom = gravity ? .top(0) : .bottom(0)
            manager.popMenuAppearance.popMenuFont = .systemFont(ofSize: 17, weight: .medium)
            manager.popMenuAppearance.popMenuColor.actionColor = .tint(tint)
            manager.popMenuDidDismiss = { didSelect in
                if !didSelect { callback(nil) }
            }
            
            var frame: CGRect?
            var sourceView: UIView?
            if options["frame"] != nil {
                frame = RCTConvert.cgRect(options["frame"])
            }
            if options["nativeID"] != nil {
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                guard let rootView = window?.rootViewController?.view else { return }
                sourceView = rootView.find(options["nativeID"] as! String)
            }
            if frame == nil && sourceView == nil {
                fatalError("Cant present menu bacause frame or nativeID is nil")
            }
            manager.present(sourceRect: frame, sourceView: sourceView)
        }
    }
}


extension UIView {
    func find(_ nativeID: String) -> UIView? {
        if self.accessibilityLabel == nativeID || self.nativeID == nativeID {
            return self
        }
        
        for subview in subviews {
            if let v = subview.find(nativeID) {
                return v
            }
        }
        
        return nil
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
