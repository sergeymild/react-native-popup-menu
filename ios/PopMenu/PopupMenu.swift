import React

@objc(PopupMenu)
class PopupMenu: NSObject {
    private var baseOptions: NSDictionary?
    
    @objc
    func configurePopup(_ options: NSDictionary) {
        self.baseOptions = options
    }
    
    @objc
    func showPopup(_ options: NSDictionary, callback: @escaping RCTResponseSenderBlock) {
        
        DispatchQueue.main.async { [self] in
            var items: [ContextMenuItem] = []
            
            let buttons = options["buttons"] as! [[String: Any]]
            for (_, button) in buttons.enumerated() {
                var icon: UIImage?
                if let i = button["icon"] as? String,
                   let url = URL(string: i),
                   let data = try? Data(contentsOf: url) {
                    icon = UIImage(data: data)
                }
                
                let baseItem = baseOptions?["item"] as? [String: Any]
                let iconColor = RCTConvert.uiColor(button["iconTint"] ?? baseItem?["iconTint"])
                let textColor = RCTConvert.uiColor(button["textColor"] ?? baseItem?["textColor"])
                let iconSize = RCTConvert.cgFloat(button["iconSize"] ?? baseItem?["iconSize"] ?? 20)
                
                let itemFontSize = RCTConvert.cgFloat(button["fontSize"] ?? baseItem?["fontSize"] ?? 17)
                var itemFont: UIFont = .systemFont(ofSize: itemFontSize)
                if let family = baseItem?["fontFamily"] as? String {
                    itemFont = UIFont(name: family, size: itemFontSize)!
                }
                
                items.append(ContextMenuItem(
                    title: button["text"] as! String,
                    image: icon,
                    itemHeight: RCTConvert.cgFloat(baseItem?["height"] ?? 48),
                    iconSize: iconSize,
                    separatorHeight: RCTConvert.cgFloat(button["separatorHeight"] ?? baseItem?["separatorHeight"] ?? 0),
                    separatorColor: RCTConvert.uiColor(button["separatorColor"] ?? baseItem?["separatorColor"] ?? 0),
                    tintColor: iconColor!,
                    textColor: textColor!,
                    font: itemFont,
                    horizontalPadding: RCTConvert.cgFloat(baseItem?["paddingHorizontal"] ?? 16),
                    textAlign: options["textAlign"] as? String
                ))
            }

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
            
            let style = Style(
                backgroundColor: RCTConvert.uiColor(baseOptions?["backgroundColor"]) ?? .white,
                cornerRadius: RCTConvert.cgFloat(baseOptions?["cornerRadius"] ?? 20)
            )
            
            if let w = (options["minWidth"] ?? baseOptions?["minWidth"]) as? NSNumber {
                CM.minWidth = CGFloat(w.floatValue)
            }
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
