@objc(PopupMenu)
class PopupMenu: NSObject {
    
    @objc
    func configurePopup(_ options: NSDictionary) {
        configure(options)
        
        
        if options["backgroundColor"] == nil {
            var isDark = false
            if #available(iOS 12.0, *) {
                isDark = UIScreen.main.traitCollection.userInterfaceStyle == .dark
            }
            if let theme = options["theme"] as? String {
                isDark = theme == "dark"
            }
            PopMenuManager.default.popMenuAppearance.popMenuColor.backgroundColor =
                .solid(fill: isDark ? .black : .white)
        }
        
    }
    
    private func configure(_ options: NSDictionary) {
        var isDark = false
        if #available(iOS 12.0, *) {
            isDark = UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
        if let theme = options["theme"] as? String {
            isDark = theme == "dark"
        }
        
        
        let manager = PopMenuManager.default
        
        let gravity = options["gravity"] as? String == "top"
        let tint: UIColor = isDark ? .white : .black
        
        if options["isIconsFromRight"] != nil {
            let rightIcon = (options["isIconsFromRight"] as? Bool) == true
            manager.popMenuAppearance.rightIcon = rightIcon
        }
        
        if let radius = options["cornerRadius"] as? Double {
            manager.popMenuAppearance.popMenuCornerRadius = radius
        }
        
        if let height = options["itemHeight"] as? Double {
            manager.popMenuAppearance.popMenuActionHeight = height
        }
        
        if let size = options["itemFontSize"] as? Double {
            manager.popMenuAppearance.popMenuFont = manager.popMenuAppearance.popMenuFont.withSize(size)
        }
        
        if let size = options["itemIconSize"] as? Double {
            manager.popMenuAppearance.popMenuActionIconSize = size
        }
        
        if let padding = options["itemPaddingHorizontal"] as? Double {
            manager.popMenuAppearance.popMenuActionPaddingHorizontal = padding
        }
        
        if options["backgroundColor"] != nil {
            manager.popMenuAppearance.popMenuColor.backgroundColor =
                .solid(fill: RCTConvert.uiColor(options["backgroundColor"]))
        }
        
        manager.popMenuAppearance.popMenuBackgroundStyle = .none()
        manager.popMenuAppearance.popMenuGravityBottom = gravity ? .top(0) : .bottom(0)
        manager.popMenuAppearance.popMenuColor.actionColor = .tint(tint)
    }
    
    @objc
    func showPopup(_ options: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
        
        DispatchQueue.main.async { [self] in
            
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
                    PopMenuAction(
                        title: button["text"] as? String,
                        image: icon,
                        color: color,
                        didSelect: { _ in callback([index]) },
                        separator: separator(value: button)
                    ))
            }
            
            let originalTheme = manager.popMenuAppearance
            self.configure(options)
            debugPrint(originalTheme)
            
            
            manager.popMenuDidDismiss = { didSelect in
                if !didSelect { callback(nil) }
                manager.popMenuAppearance = originalTheme
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

func separator(value: [String: Any]) -> PopMenuActionSeparator {
    if (value["showSeparator"] as? Bool) != true {
        return .none()
    }
    let color = RCTConvert.uiColor(value["separatorColor"] as? NSNumber)
    let height = (value["separatorHeight"] as? Double) ?? 1
    return .fill(color, height: height)
}

func hexStringToUIColor (hex: String?) -> UIColor? {
    guard let hex = hex else { return nil }
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
