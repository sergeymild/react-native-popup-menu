import React

@objc(PopupMenu)
class PopupMenu: NSObject {
    private var baseOptions: NSDictionary?
    
    @objc
    func configurePopup(_ options: NSDictionary) {
        self.baseOptions = options
        //configure(options)
//
//        if let height = options["separatorHeight"] as? Double {
//            PopMenuManager.default.popMenuAppearance.separator =
//                .fill(PopMenuManager.default.popMenuAppearance.separator.color,
//                      height: height
//                )
//        }
//
//        if options["separatorColor"] != nil {
//            PopMenuManager.default.popMenuAppearance.separator =
//                .fill(RCTConvert.uiColor(options["separatorColor"]),
//                      height: PopMenuManager.default.popMenuAppearance.separator.height
//                )
//        }
//
//        if options["tint"] != nil {
//            PopMenuManager.default.popMenuAppearance.popMenuColor.actionColor =
//                .tint(RCTConvert.uiColor(options["tint"]))
//        }
//
//        if options["shadow"] != nil {
//            let shadow = options["shadow"] as! [String: Any]
//
//            PopMenuManager.default.popMenuAppearance.shadow = .init(
//                offset: RCTConvert.cgSize(shadow["offset"]),
//                color: RCTConvert.uiColor(shadow["color"]),
//                radius: RCTConvert.cgFloat(shadow["radius"]),
//                opacity: RCTConvert.float(shadow["opacity"])
//            )
//        }
        
    }
    
    private func configure(_ options: NSDictionary) {
        
//        let manager = PopMenuManager.default
//
//        let gravity = options["gravity"] as? String == "top"
//
//        if options["isIconsFromRight"] != nil {
//            let rightIcon = (options["isIconsFromRight"] as? Bool) == true
//            manager.popMenuAppearance.rightIcon = rightIcon
//        }
//
//        if let radius = options["cornerRadius"] as? Double {
//            manager.popMenuAppearance.popMenuCornerRadius = radius
//        }
//
//        if let height = options["itemHeight"] as? Double {
//            manager.popMenuAppearance.popMenuActionHeight = height
//        }
//
//        if let family = options["itemFontFamily"] as? String {
//            manager.popMenuAppearance.popMenuFont = UIFont(
//                name: family,
//                size: manager.popMenuAppearance.popMenuFont.pointSize
//            )!
//        }
//
//        if let size = options["itemFontSize"] as? Double {
//            manager.popMenuAppearance.popMenuFont = manager.popMenuAppearance.popMenuFont.withSize(size)
//        }
//
//        if let size = options["itemIconSize"] as? Double {
//            manager.popMenuAppearance.popMenuActionIconSize = size
//        }
//
//        if let padding = options["itemPaddingHorizontal"] as? Double {
//            manager.popMenuAppearance.popMenuActionPaddingHorizontal = padding
//        }
//
//        if options["backgroundColor"] != nil {
//            manager.popMenuAppearance.popMenuColor.backgroundColor =
//                .solid(fill: RCTConvert.uiColor(options["backgroundColor"]))
//        }
//        manager.popMenuAppearance.popMenuGravityBottom = gravity ? .top(0) : .bottom(0)
    }
    
    @objc
    func showPopup(_ options: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
        
        DispatchQueue.main.async { [self] in
            var items: [ContextMenuItem] = []
            
            let buttons = options["buttons"] as! [[String: Any]]
            for (index, button) in buttons.enumerated() {
                var icon: UIImage?
                if let i = button["icon"] as? String,
                   let url = URL(string: i),
                   let data = try? Data(contentsOf: url) {
                    icon = UIImage(data: data)
                }
                
                let baseItem = baseOptions?["item"] as? [String: Any]
                var color = RCTConvert.uiColor(baseItem?["tint"])
//
                if button["tint"] != nil {
                    color = RCTConvert.uiColor(button["tint"])
                }
                
                var itemFontSize = RCTConvert.cgFloat(baseItem?["fontSize"] ?? 17)
                var itemFont: UIFont = .systemFont(ofSize: itemFontSize)
                if let family = baseItem?["fontFamily"] as? String {
                    itemFont = UIFont(name: family, size: itemFontSize)!
                }
                
                items.append(ContextMenuItem(
                    title: button["text"] as! String,
                    image: icon,
                    itemHeight: RCTConvert.cgFloat(baseItem?["height"] ?? 48),
                    iconSize: RCTConvert.cgFloat(baseItem?["iconSize"] ?? 20),
                    separatorHeight: RCTConvert.cgFloat(button["separatorHeight"] ?? baseItem?["separatorHeight"] ?? 0),
                    separatorColor: RCTConvert.uiColor(button["separatorColor"] ?? baseItem?["separatorColor"] ?? 0),
                    tintColor: color!,
                    font: itemFont,
                    horizontalPadding: RCTConvert.cgFloat(baseItem?["paddingHorizontal"] ?? 16)
                ))
//
//
//                manager.actions.append(
//                    PopMenuAction(
//                        title: button["text"] as? String,
//                        image: icon,
//                        color: color.color,
//                        didSelect: { _ in callback([index]) },
//                        separator: separator(value: button)
//                    ))
            }
            
//
//            let originalTheme = manager.popMenuAppearance
//            self.configure(options)
//            debugPrint(originalTheme)
//
//
//            manager.popMenuDidDismiss = { didSelect in
//                if !didSelect { callback(nil) }
//                manager.popMenuAppearance = originalTheme
//            }
//
            var frame: CGRect?
            if options["frame"] != nil {
                frame = RCTConvert.cgRect(options["frame"])
            }

            if frame == nil {
                fatalError("Cant present menu bacause frame or nativeID is nil")
            }
            
            let baseShadow = baseOptions?["shadow"] as? [String: Any]
            let shadow = Shadow(
                shadowOffset: RCTConvert.cgSize(baseShadow?["offset"]),
                shadowOpacity: RCTConvert.cgFloat(baseShadow?["opacity"]),
                shadowRadius: RCTConvert.cgFloat(baseShadow?["radius"]),
                shadowColor: RCTConvert.uiColor(baseShadow?["color"]) ?? .clear)
            
            let style = Style(backgroundColor: RCTConvert.uiColor(baseOptions?["backgroundColor"]) ?? .white)
            
            CM.items = items
            CM.showMenu(frame: frame!, shadow: shadow, style: style)
            
            var didSelect = false
            CM.contextMenuDidDisappear = {
                if !didSelect { callback(nil) }
            }

            CM.didItemSelect = { item, index in
                debugPrint(index)
                didSelect = true
                callback([index.row])
            }
        }
    }
}

extension PopupMenu : ContextMenuDelegate {
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool {
        return true
    }
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, didSelect item: ContextMenuItem, forRowAt index: Int) {
        
    }
    
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("contextMenuDidAppear")
    }
    
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
        print("contextMenuDidDisappear")
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

//func separator(value: [String: Any]) -> PopMenuActionSeparator {
//    if (value["showSeparator"] as? Bool) != true {
//        return .none()
//    }
//    var color = PopMenuManager.default.popMenuAppearance.separator.color
//    if value["separatorColor"] != nil {
//        color = RCTConvert.uiColor(value["separatorColor"] as? NSNumber)
//    }
//
//    let height = (value["separatorHeight"] as? Double) ?? PopMenuManager.default.popMenuAppearance.separator.height
//    return .fill(color, height: height)
//}

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
