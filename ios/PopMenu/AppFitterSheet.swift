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
            (subview as RCTShadowView).width = YGValue.init(value: Float(RCTScreenSize().width), unit: .point)
            subview.position = .absolute
        }
    }
}

let FITTED_SHEET_SCROLL_VIEW = "fittedSheetScrollView"

@objc(AppFitterSheet)
class AppFitterSheet: RCTViewManager {
    var sheetView: UIView?

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    override func customBubblingEventTypes() -> [String]! {
        return ["onSheetDismiss"]
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
    var _sheetSize: NSNumber?

    @objc
    private var onSheetDismiss: RCTBubblingEventBlock?

    @objc
    func setSheetSize(_ value: NSNumber) {
        if value == -1 { return }
        _sheetSize = value
        if _isPresented, let reactSubView = _reactSubview {
            let newHeight = CGFloat(value.floatValue)
            if reactSubView.frame.height == newHeight { return }
            let sizes: [SheetSize] = [.fixed(newHeight)]
            self._modalViewController?.sizes = sizes
            self._modalViewController?.resize(to: sizes[0], animated: true)
            self.notifyForBoundsChange(newBounds: .init(width: reactSubView.frame.width, height: newHeight))
            debugPrint("updateVisibleFittedSheetSize", newHeight)
        }
    }

    @objc
    func setIncreaseHeight(_ by: NSNumber) {
        if by.floatValue == 0 { return }
        debugPrint("setIncreaseHeight", by.floatValue)
        changeHeight(by.floatValue)
    }

    @objc
    func setDecreaseHeight(_ by: NSNumber) {
        if by.floatValue == 0 { return }
        debugPrint("setDecreaseHeight", -by.floatValue)
        changeHeight(-by.floatValue)
    }

    private func changeHeight(_ by: Float) {
        if !_isPresented { return }
        guard let reactSubView = _reactSubview else { return }

        let newHeight = CGFloat(by)
        if reactSubView.frame.height == newHeight { return }
        let increasedHeight = reactSubView.frame.height + newHeight
        debugPrint("changeHeight from", reactSubView.frame.height, "to", increasedHeight)
        let sizes: [SheetSize] = [.fixed(increasedHeight)]
        self._modalViewController?.sizes = sizes
        self._modalViewController?.resize(to: sizes[0], animated: true)
        self.notifyForBoundsChange(newBounds: .init(width: reactSubView.frame.width, height: increasedHeight))
        debugPrint("", increasedHeight)
    }

    @objc
    private var sheetMaxWidthSize: NSNumber?
    @objc
    private var sheetMaxHeightSize: NSNumber?
    @objc
    private var topLeftRightCornerRadius: NSNumber?

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
//          _bridge?.uiManager.setSize(.init(width: newBounds.width, height: 100), for: _reactSubview!)


          let registery = self._bridge?.uiManager.value(forKey: "_shadowViewRegistry") as? [NSNumber: RCTShadowView]
          let shadowView = registery?[self._reactSubview!.reactTag]
          let origin = shadowView?.layoutMetrics.frame ?? .zero
          shadowView?.size = .init(width: newBounds.width, height: newBounds.height)
          shadowView?.onLayout?([
            "layout": [
                "x": "\(origin.origin.x)",
                "y": "\(origin.origin.y)",
                "width": "\(newBounds.width)",
                "height": "\(newBounds.height)"
            ]
          ])
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

    // need to leave it empty
    override func didUpdateReactSubviews() {}

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
                if self._sheetSize?.floatValue == nil {
                    self._reactSubview?.setNeedsLayout()
                    self._reactSubview?.layoutIfNeeded()
                    self._reactSubview?.sizeToFit()
                    size = self._reactSubview?.frame.size ?? .zero
                } else {
                    size = .init(width: self.sheetWidth, height: CGFloat(self._sheetSize!.floatValue))
                }
                if size.width > self.sheetWidth {
                    size.width = self.sheetWidth
                }
                if self.sheetMaxHeightSize != nil && size.height > self.sheetMaxHeightSize!.doubleValue {
                    size.height = self.sheetMaxHeightSize!.doubleValue
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
                self._modalViewController?.cornerRadius = self.topLeftRightCornerRadius?.doubleValue ?? 12

                let scrollView = self._reactSubview?.find(FITTED_SHEET_SCROLL_VIEW, deepIndex: 0) as? RCTScrollView
                if scrollView != nil {
                    self._modalViewController?.handleScrollView(scrollView!.scrollView)
                }

                self.reactViewController().present(self._modalViewController!, animated: true)

                self._modalViewController?.didDismiss = { [weak self] _ in
                    debugPrint("🥲didDismiss")
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
        if self._modalViewController?.isBeingDismissed != true {
            debugPrint("🥲dismissViewController")
            self._modalViewController?.dismiss(animated: true)
        }
        _modalViewController = nil
        _reactSubview?.removeFromSuperview()
        _touchHandler?.detach(from: _reactSubview)
        _touchHandler = nil
        _bridge = nil
        manager?.sheetView = nil
        onSheetDismiss = nil
        _sheetSize = nil
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
