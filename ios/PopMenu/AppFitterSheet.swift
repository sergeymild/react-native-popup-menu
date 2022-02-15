//
//  AppFitterSheet.swift
//  PopupMenu
//
//  Created by Sergei Golishnikov on 14/02/2022.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import UIKit
import React
import FittedSheets

class ModalHostShadowView: RCTShadowView {
    override func insertReactSubview(_ subview: RCTShadowView!, at atIndex: Int) {
        super.insertReactSubview(subview, at: atIndex)
//        if subview != nil {
//            (subview as RCTShadowView).size = RCTScreenSize()
//        }
    }
}

@objc(AppFitterSheet)
class AppFitterSheet: RCTViewManager {
    var sheetView: UIView?
    
    override func customBubblingEventTypes() -> [String]! {
        return ["dismiss"]
    }
    
    override class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func view() -> UIView! {
        let v = HostFittetSheet(bridge: bridge, manager: self)
        sheetView = v
        return v
    }
    
    @objc
    func dismiss() {
        debugPrint("🥲dismiss")
    }
    
    override func shadowView() -> RCTShadowView! {
        return ModalHostShadowView()
    }
    
    deinit {
        debugPrint("🥲 deinit view manager")
    }
}


class HostFittetSheet: UIView {
    var _modalViewController: SheetViewController?
    let viewController = UIViewController()
    var _touchHandler: RCTTouchHandler?
    var _reactSubview: UIView?
    var _bridge: RCTBridge?
    weak var manager: AppFitterSheet?
    var _isPresented = false
    
    @objc
    private var onDismiss: RCTBubblingEventBlock? {
        didSet {
            debugPrint("ds")
        }
    }
    
    @objc
    var sheetSize: NSNumber? {
        didSet {
            if _isPresented {
                let sizes: [SheetSize] = [.fixed(CGFloat(sheetSize!.floatValue))]
                self._modalViewController?.sizes = sizes
                self._modalViewController?.resize(to: sizes[0], animated: true)
            }
        }
    }
    
    @objc
    private var sheetMaxWidthSize: NSNumber?
    
    private var sheetWidth: CGFloat {
        return CGFloat(sheetMaxWidthSize?.floatValue ?? Float(UIScreen.main.bounds.width))
    }
    
    init(bridge: RCTBridge, manager: AppFitterSheet) {
        self._bridge = bridge
        self.manager = manager
        super.init(frame: .zero)
        _touchHandler = RCTTouchHandler(bridge: bridge)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func notifyForBoundsChange(newBounds: CGSize) {
      if (_reactSubview != nil && _isPresented) {
          _bridge?.uiManager.setSize(newBounds, for: _reactSubview!)
      }
    }
    
    
    
    override func insertReactSubview(_ subview: UIView!, at atIndex: Int) {
        debugPrint("🥲insertReactSubview")
        super.insertReactSubview(subview, at: atIndex)
        _touchHandler?.attach(to: subview)
        viewController.view.insertSubview(subview, at: 0)
        _reactSubview = subview
    }
    
    override func removeReactSubview(_ subview: UIView!) {
        debugPrint("🥲removeReactSubview")
        super.removeReactSubview(subview)
        destroy()
    }
    
    override func didUpdateReactSubviews() {
        
    }
    
    override func didMoveToWindow() {
        if (!_isPresented && self.window != nil) {
            _isPresented = true
            var size: CGSize = .zero
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.sheetSize?.floatValue == nil {
                    self._reactSubview?.setNeedsLayout()
                    self._reactSubview?.layoutIfNeeded()
                    self._reactSubview?.sizeToFit()
                    size = self._reactSubview?.frame.size ?? .zero
                } else {
                    size = .init(width: self.sheetWidth, height: CGFloat(self.sheetSize!.floatValue))
                }
                self.notifyForBoundsChange(newBounds: size)
                self._modalViewController = SheetViewController(
                    controller: self.viewController,
                    sizes: [.fixed(size.height)],
                    options: .init(maxWidth: self.sheetWidth)
                )
                
                //let f = self._reactSubview?.subviews[0] as! RCTScrollView
                //self._modalViewController?.handleScrollView(f.scrollView)

                self.reactViewController().present(self._modalViewController!, animated: true)
                
                self._modalViewController?.didDismiss = { [weak self] _ in
                    self?.onDismiss?([:])
                }
            }
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        debugPrint("🥲removeFromSuperview")
        destroy()
    }
    
    func destroy() {
        debugPrint("🥲destroy")
        _isPresented = false
        _modalViewController = nil
        _reactSubview?.removeFromSuperview()
        _touchHandler?.detach(from: _reactSubview)
        _touchHandler = nil
        _bridge = nil
        manager?.sheetView = nil
        onDismiss = nil
    }
    
    deinit {
        debugPrint("🥲deinit")
    }

}
