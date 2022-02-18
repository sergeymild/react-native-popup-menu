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
        if subview != nil {
            (subview as RCTShadowView).size = RCTScreenSize()
            subview.position = .absolute
        }
    }
}

let FITTED_SHEET_SCROLL_VIEW = "fittedSheetScrollView"

@objc(AppFitterSheet)
class AppFitterSheet: RCTViewManager {
    var sheetView: UIView?
    
    override func customBubblingEventTypes() -> [String]! {
        return ["onSheetDismiss"]
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
    private var onSheetDismiss: RCTBubblingEventBlock? {
        didSet {
            debugPrint("ds")
        }
    }
    
    @objc
    var sheetSize: NSNumber? {
        didSet {
            debugPrint("🥲sheetSize", sheetSize?.floatValue)
            if _isPresented && sheetSize != nil {
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
        _touchHandler?.detach(from: subview)
        _reactSubview = nil
        //destroy()
    }
    
    override func didUpdateReactSubviews() {
        debugPrint("🥲didUpdateReactSubviews", _reactSubview?.superview?.accessibilityLabel)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // In the case where there is a LayoutAnimation, we will be reinserted into the view hierarchy but only for aesthetic
        // purposes. In such a case, we should NOT represent the <Modal>.
        
        if (!self.isUserInteractionEnabled && self.superview?.reactSubviews().contains(self) != nil) {
          return;
        }
        
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
                    options: .init(
                        pullBarHeight: 0,
                        shouldExtendBackground: false,
                        shrinkPresentingViewController: false,
                        maxWidth: self.sheetWidth
                    )
                )
                self._modalViewController?.allowPullingPastMaxHeight = false
                self._modalViewController?.autoAdjustToKeyboard = false
                
                let scrollView = self._reactSubview?.find(FITTED_SHEET_SCROLL_VIEW, deepIndex: 0) as? RCTScrollView
                if scrollView != nil {
                    self._modalViewController?.handleScrollView(scrollView!.scrollView)
                }

                self.reactViewController().present(self._modalViewController!, animated: true)
                
                self._modalViewController?.didDismiss = { [weak self] _ in
                    self?.onSheetDismiss?([:])
                }
            }
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        debugPrint("🥲removeFromSuperview")
        //destroy()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if _isPresented && superview == nil {
            debugPrint("🥲didMoveToSuperview")
            destroy()
        }
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
        onSheetDismiss = nil
        sheetSize = nil
        sheetMaxWidthSize = nil
    }
    
    deinit {
        debugPrint("🥲deinit")
    }

}


extension UIView {
    func find(_ nativeID: String, deepIndex: Int) -> UIView? {
        if deepIndex >= 10 { return nil }
        if self.nativeID == nativeID {
            return self
        }
        
        let index = deepIndex + 1
        for subview in subviews {
            if let v = subview.find(nativeID, deepIndex: index) {
                return v
            }
        }
        
        return nil
    }
}
