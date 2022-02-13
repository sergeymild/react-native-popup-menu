//
//  CustomFocusedView.swift
//  Seekr
//
//  Created by macmin on 29/04/2020.
//  Copyright © 2020 macmin. All rights reserved.
//

import UIKit


public struct ContextMenuItem {
    
    public let title: String
    public let image: UIImage?
    public let separatorHeight: CGFloat
    public let itemHeight: CGFloat
    public let iconSize: CGFloat
    public let tintColor: UIColor
    public let separatorColor: UIColor
    public let font: UIFont
    public let horizontalPadding: CGFloat
    
    public init(
        title: String,
        image: UIImage?,
        itemHeight: CGFloat,
        iconSize: CGFloat,
        separatorHeight: CGFloat,
        separatorColor: UIColor,
        tintColor: UIColor,
        font: UIFont,
        horizontalPadding: CGFloat
    ) {
        self.title = title
        self.image = image
        self.itemHeight = itemHeight
        self.iconSize = iconSize
        self.separatorColor = separatorColor
        self.separatorHeight = separatorHeight
        self.tintColor = tintColor
        self.font = font
        self.horizontalPadding = horizontalPadding
    }
}

public protocol ContextMenuDelegate : AnyObject {
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int)
    func contextMenuDidAppear(_ contextMenu: ContextMenu)
    func contextMenuDidDisappear(_ contextMenu: ContextMenu)
}
extension ContextMenuDelegate {
    func contextMenuDidAppear(_ contextMenu: ContextMenu){}
    func contextMenuDidDisappear(_ contextMenu: ContextMenu){}
}

public var CM : ContextMenu = ContextMenu()

public struct ContextMenuConstants {
    public var MaxZoom : CGFloat = 1.15
    public var MinZoom : CGFloat = 0.6
    public var menuDefaultHeight : CGFloat = 120
    public var MenuWidth : CGFloat = 250
    public var menuMarginSpace : CGFloat = 16
    public var TopMarginSpace : CGFloat = 0
    public var BottomMarginSpace : CGFloat = 24
    public var horizontalMarginSpace : CGFloat = 16

    public var ItemDefaultColor = UIColor.white
    
    public var MenuCornerRadius : CGFloat = 20
    public var BlurEffectEnabled : Bool = false
    public var BlurEffectDefault = UIBlurEffect(style: .dark)
    public var BackgroundViewColor = UIColor.black.withAlphaComponent(0.2)
}

open class ContextMenu: NSObject {
    
    // MARK:- open Variables
    open var MenuConstants = ContextMenuConstants()
    open var viewTargeted: UIView!
    open var placeHolderView : UIView?
    open var headerView : UIView?
    open var footerView : UIView?
    open var closeAnimation = true
    
    open var onItemTap : ((_ index: Int, _ item: ContextMenuItem) -> Bool)?
    open var onViewAppear : ((UIView) -> Void)?
    open var onViewDismiss : ((UIView) -> Void)?
    
    open var items = [ContextMenuItem]()
    
    // MARK:- Private Variables
    private weak var delegate : ContextMenuDelegate?
    
    private var mainViewRect : CGRect
    private var customView = UIView()
    private var blurEffectView = UIVisualEffectView()
    private var targetedImageView = UIImageView()
    private var menuView = UIView()
    public var tableView = UITableView()
    private var tableViewConstraint : NSLayoutConstraint?
    private var zoomedTargetedSize = CGRect()
    
    private var menuHeight : CGFloat = 180
    private var isLandscape : Bool = false
    
    private var touchGesture : UITapGestureRecognizer?
    private var closeGesture : UITapGestureRecognizer?
    
    private var tvH : CGFloat = 0.0
    private var tvW : CGFloat = 0.0
    private var tvY : CGFloat = 0.0
    private var tvX : CGFloat = 0.0
    private var mH : CGFloat = 0.0
    private var mW : CGFloat = 0.0
    private var mY : CGFloat = 0.0
    private var mX : CGFloat = 0.0
    
    // MARK:- Init Functions
    public init(window: UIView? = nil) {
        let wind = window ?? UIApplication.shared.windows.first ?? UIApplication.shared.keyWindow
        self.customView = wind!
        self.mainViewRect = wind!.frame
    }
    
    init?(viewTargeted: UIView, window: UIView? = nil) {
        if let wind = window ?? UIApplication.shared.windows.first ?? UIApplication.shared.keyWindow {
            self.customView = wind
            self.viewTargeted = viewTargeted
            self.mainViewRect = self.customView.frame
        } else {
            return nil
        }
    }
    
    init(viewTargeted: UIView, window: UIView) {
        self.viewTargeted = viewTargeted
        self.customView = window
        self.mainViewRect = window.frame
    }
    
    private func calculateHeight() {
        if !self.items.isEmpty {
            var height: CGFloat = 0
            var index = 0
            for item in self.items {
                height += item.itemHeight
                if index != self.items.count - 1 {
                    height += item.separatorHeight
                }
                index += 1
            }
            self.menuHeight = height + (self.headerView?.frame.height ?? 0) + (self.footerView?.frame.height ?? 0)
            return
        }
        self.menuHeight = self.MenuConstants.menuDefaultHeight
        
        debugPrint(self.menuHeight)
    }
    
    // MARK:- Show, Change, Update Menu Functions
    open func showMenu(viewTargeted: UIView, delegate: ContextMenuDelegate, animated: Bool = true) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        DispatchQueue.main.async {
            self.delegate = delegate
            self.viewTargeted = viewTargeted
            self.calculateHeight()
            self.addBlurEffectView()
            self.addMenuView()
            self.addTargetedImageView()
            self.openAllViews()
        }
    }
    
    open func changeViewTargeted(newView: UIView, animated: Bool = true) {
        DispatchQueue.main.async {
            guard self.viewTargeted != nil else{
                print("targetedView is nil")
                return
            }
            self.viewTargeted.alpha = 1
            if let gesture = self.touchGesture {
                self.viewTargeted.removeGestureRecognizer(gesture)
            }
            self.viewTargeted = newView
            self.targetedImageView.image = self.getRenderedImage(afterScreenUpdates: true)
            if let gesture = self.touchGesture {
                self.viewTargeted.addGestureRecognizer(gesture)
            }
            self.updateTargetedImageViewPosition(animated: animated)
        }
    }
    
    open func updateView(animated: Bool = true) {
        DispatchQueue.main.async {
            guard self.viewTargeted != nil else {
                print("targetedView is nil")
                return
            }
            guard self.customView.subviews.contains(self.targetedImageView) else {return}
            self.calculateHeight()
            self.viewTargeted.alpha = 0
            self.addMenuView()
            self.updateTargetedImageViewPosition(animated: animated)
        }
    }
    
    open func closeMenu(){
        self.closeAllViews()
    }
    
    open func closeMenu(withAnimation animation: Bool) {
        closeAllViews(withAnimation: animation)
    }
    
    // MARK:- Get Rendered Image Functions
    func getRenderedImage(afterScreenUpdates: Bool = false) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: viewTargeted.bounds.size)
        let viewSnapShotImage = renderer.image { ctx in
            viewTargeted.contentScaleFactor = 3
            viewTargeted.drawHierarchy(in: viewTargeted.bounds, afterScreenUpdates: afterScreenUpdates)
        }
        return viewSnapShotImage
    }
    
    func addBlurEffectView() {
        
        if !customView.subviews.contains(blurEffectView) {
            customView.addSubview(blurEffectView)
        }
        
        if MenuConstants.BlurEffectEnabled {
            blurEffectView.effect = MenuConstants.BlurEffectDefault
            blurEffectView.backgroundColor = .clear
        } else {
            blurEffectView.effect = nil
            blurEffectView.backgroundColor = MenuConstants.BackgroundViewColor
        }
        
        blurEffectView.frame = CGRect(
            x: mainViewRect.origin.x,
            y: mainViewRect.origin.y,
            width: mainViewRect.width,
            height: mainViewRect.height
        )
        
        if closeGesture == nil {
            blurEffectView.isUserInteractionEnabled = true
            closeGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissViewAction(_:)))
            blurEffectView.addGestureRecognizer(closeGesture!)
        }
    }
    
    @objc func dismissViewAction(_ sender: UITapGestureRecognizer? = nil){
        self.closeAllViews()
    }
    
    func addTargetedImageView(){
        
        if !customView.subviews.contains(targetedImageView) {
            customView.addSubview(targetedImageView)
        }
        
        let rect = viewTargeted.convert(mainViewRect.origin, to: nil)
        
        targetedImageView.image = self.getRenderedImage()
        targetedImageView.frame = CGRect(
            x: rect.x,
            y: rect.y,
            width: viewTargeted.frame.width,
            height: viewTargeted.frame.height
        )
        
        targetedImageView.layer.shadowColor = UIColor.black.cgColor
        targetedImageView.layer.shadowRadius = 16
        targetedImageView.layer.shadowOpacity = 0
        targetedImageView.isUserInteractionEnabled = true
        
    }
    
    func addMenuView(){
        
        if !customView.subviews.contains(menuView) {
            customView.addSubview(menuView)
            tableView = UITableView()
        }else{
            tableView.removeFromSuperview()
            tableView = UITableView()
        }
        
        let rect = viewTargeted.convert(mainViewRect.origin, to: nil)
        
        menuView.backgroundColor = MenuConstants.ItemDefaultColor
        menuView.layer.cornerRadius = MenuConstants.MenuCornerRadius
        menuView.clipsToBounds = true
        menuView.frame = CGRect(
            x: rect.x,
            y: rect.y,
            width: self.viewTargeted.frame.width,
            height: self.viewTargeted.frame.height
        )
        
        menuView.addSubview(tableView)
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = menuView.bounds
        tableView.register(ContextMenuCell.self, forCellReuseIdentifier: "ContextMenuCell")
        tableView.tableHeaderView = self.headerView
        tableView.tableFooterView = self.footerView
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = false
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = .clear
        tableView.reloadData()
    }
    
    func openAllViews(animated: Bool = true){
        let rect = self.viewTargeted.convert(self.mainViewRect.origin, to: nil)
        viewTargeted.alpha = 0
        //        customView.backgroundColor = .clear
        blurEffectView.alpha = 0
        targetedImageView.alpha = 1
        targetedImageView.layer.shadowOpacity = 0.0
        targetedImageView.isUserInteractionEnabled = true
        targetedImageView.frame = CGRect(x: rect.x, y: rect.y, width: self.viewTargeted.frame.width, height: self.viewTargeted.frame.height)
        menuView.alpha = 0
        menuView.isUserInteractionEnabled = true
        //        menuView.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
        menuView.frame = CGRect(x: rect.x, y: rect.y, width: self.viewTargeted.frame.width, height: self.viewTargeted.frame.height)
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.blurEffectView.alpha = 1
                self.targetedImageView.layer.shadowOpacity = 0.2
            }
        } else {
            self.blurEffectView.alpha = 1
            self.targetedImageView.layer.shadowOpacity = 0.2
        }
        self.updateTargetedImageViewPosition(animated: animated)
        self.onViewAppear?(self.viewTargeted)
        
        self.delegate?.contextMenuDidAppear(self)
    }
    
    func closeAllViews(){
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        DispatchQueue.main.async {
            //            UIView.animate(withDuration: 0.2, animations: {
            //                self.blurEffectView.alpha = 0
            //                self.targetedImageView.layer.shadowOpacity = 0
            //            }) { (_) in
            //                self.viewTargeted.alpha = 1
            //                self.customView.removeFromSuperview()
            //            }
            self.targetedImageView.isUserInteractionEnabled = false
            self.menuView.isUserInteractionEnabled = false
            
            let rect = self.viewTargeted.convert(self.mainViewRect.origin, to: nil)
            if self.closeAnimation {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.layoutSubviews, .preferredFramesPerSecond60, .allowUserInteraction], animations: {
                    self.prepareViewsForRemoveFromSuperView(with: rect)
                    //                self.menuView.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)//.translatedBy(x: 0, y: (self.menuHeight) * CGFloat((rect.y < self.menuView.frame.origin.y) ? -1 : 1) )
                    
                }) { (_) in
                    DispatchQueue.main.async {
                        self.removeAllViewsFromSuperView()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.prepareViewsForRemoveFromSuperView(with: rect)
                    self.removeAllViewsFromSuperView()
                }
            }
            self.onViewDismiss?(self.viewTargeted)
            self.delegate?.contextMenuDidDisappear(self)
        }
    }
    
    func closeAllViews(withAnimation animation: Bool = true) {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        DispatchQueue.main.async {
            self.targetedImageView.isUserInteractionEnabled = false
            self.menuView.isUserInteractionEnabled = false
            
            let rect = self.viewTargeted.convert(self.mainViewRect.origin, to: nil)
            if animation {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.layoutSubviews, .preferredFramesPerSecond60, .allowUserInteraction], animations: {
                    self.prepareViewsForRemoveFromSuperView(with: rect)
                }) { (_) in
                    DispatchQueue.main.async {
                        self.removeAllViewsFromSuperView()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.prepareViewsForRemoveFromSuperView(with: rect)
                    self.removeAllViewsFromSuperView()
                }
            }
            self.onViewDismiss?(self.viewTargeted)
            self.delegate?.contextMenuDidDisappear(self)
        }
    }
    
    func prepareViewsForRemoveFromSuperView(with rect: CGPoint) {
        self.blurEffectView.alpha = 0
        self.targetedImageView.layer.shadowOpacity = 0
        self.targetedImageView.frame = CGRect(x: rect.x, y: rect.y, width: self.viewTargeted.frame.width, height: self.viewTargeted.frame.height)
        self.menuView.alpha = 0
        self.menuView.frame = CGRect(x: rect.x, y: rect.y, width: self.viewTargeted.frame.width, height: self.viewTargeted.frame.height)
    }
    
    func removeAllViewsFromSuperView() {
        self.viewTargeted?.alpha = 1
        self.targetedImageView.alpha = 0
        self.targetedImageView.removeFromSuperview()
        self.blurEffectView.removeFromSuperview()
        self.menuView.removeFromSuperview()
        self.tableView.removeFromSuperview()
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape, !isLandscape {
            self.updateView()
            isLandscape = true
            print("Landscape")
        } else if !UIDevice.current.orientation.isLandscape, isLandscape {
            self.updateView()
            isLandscape = false
            print("Portrait")
        }
    }
    
    func getZoomedTargetedSize() -> CGRect{
        
        let rect = viewTargeted.convert(mainViewRect.origin, to: nil)
        let targetedImageFrame = viewTargeted.frame
        
        let backgroundWidth = mainViewRect.width - (2 * MenuConstants.horizontalMarginSpace)
        let backgroundHeight = mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace
        
        var zoomFactor = MenuConstants.MaxZoom
        
        //        let zoomFactorHorizontal = backgroundWidth/targetedImageFrame.width
        //        let zoomFactorVertical = backgroundHeight/targetedImageFrame.height
        //
        //        if zoomFactorHorizontal < zoomFactorVertical {
        //            zoomFactor = zoomFactorHorizontal
        //        }else{
        //            zoomFactor = zoomFactorVertical
        //        }
        //        if zoomFactor > MenuConstants.MaxZoom {
        //            zoomFactor = MenuConstants.MaxZoom
        //        }
        
        var updatedWidth = targetedImageFrame.width // * zoomFactor
        var updatedHeight = targetedImageFrame.height // * zoomFactor
        
        if backgroundWidth > backgroundHeight {
            
            let zoomFactorHorizontalWithMenu = (backgroundWidth - MenuConstants.MenuWidth - MenuConstants.menuMarginSpace)/updatedWidth
            let zoomFactorVerticalWithMenu = backgroundHeight/updatedHeight
            
            if zoomFactorHorizontalWithMenu < zoomFactorVerticalWithMenu {
                zoomFactor = zoomFactorHorizontalWithMenu
            }else{
                zoomFactor = zoomFactorVerticalWithMenu
            }
            if zoomFactor > MenuConstants.MaxZoom {
                zoomFactor = MenuConstants.MaxZoom
            }
            
            // Menu Height
            if self.menuHeight > backgroundHeight {
                self.menuHeight = backgroundHeight + MenuConstants.menuMarginSpace
            }
        }else{
            
            let zoomFactorHorizontalWithMenu = backgroundWidth/(updatedWidth)
            let zoomFactorVerticalWithMenu = backgroundHeight/(updatedHeight + self.menuHeight + MenuConstants.menuMarginSpace)
            
            if zoomFactorHorizontalWithMenu < zoomFactorVerticalWithMenu {
                zoomFactor = zoomFactorHorizontalWithMenu
            }else{
                zoomFactor = zoomFactorVerticalWithMenu
            }
            if zoomFactor > MenuConstants.MaxZoom {
                zoomFactor = MenuConstants.MaxZoom
            }else if zoomFactor < MenuConstants.MinZoom {
                zoomFactor = MenuConstants.MinZoom
            }
        }
        
        updatedWidth = (updatedWidth * zoomFactor)
        updatedHeight = (updatedHeight * zoomFactor)
        
        let updatedX = rect.x - (updatedWidth - targetedImageFrame.width)/2
        let updatedY = rect.y - (updatedHeight - targetedImageFrame.height)/2
        
        return CGRect(x: updatedX, y: updatedY, width: updatedWidth, height: updatedHeight)
        
    }
    
    func fixTargetedImageViewExtrudings(){ // here I am checking for extruding part of ImageView
        
        //        let backgroundWidth = mainViewRect.width - (2 * MenuConstants.HorizontalMarginSpace)
        //        let backgroundHeight = mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace
        //
        //        if backgroundWidth > backgroundHeight {
        //
        //        }
        //        else{
        //
        //        }
        
        if tvY > mainViewRect.height - MenuConstants.BottomMarginSpace - tvH {
            tvY = mainViewRect.height - MenuConstants.BottomMarginSpace - tvH
        }
        else if tvY < MenuConstants.TopMarginSpace {
            tvY = MenuConstants.TopMarginSpace
        }
        
        if tvX < MenuConstants.horizontalMarginSpace {
            tvX = MenuConstants.horizontalMarginSpace
            //            mX = MenuConstants.HorizontalMarginSpace
        }
        else if tvX > mainViewRect.width - MenuConstants.horizontalMarginSpace - tvW {
            tvX = mainViewRect.width - MenuConstants.horizontalMarginSpace - tvW
            //            mX = mainViewRect.width - MenuConstants.HorizontalMarginSpace - mW
        }
        
        //        if mY
    }
    
    
    
    //    func fixHorizontalTargetedImageViewExtruding(){
    //
    //        let backgroundWidth = mainViewRect.width - (2 * MenuConstants.HorizontalMarginSpace)
    //        let backgroundHeight = mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace
    //
    //
    //
    //    }
    
    func updateHorizontalTargetedImageViewRect(){
        
        let rightClippedSpace = (tvW + MenuConstants.menuMarginSpace + mW + tvX + MenuConstants.horizontalMarginSpace) - mainViewRect.width
        let leftClippedSpace = -(tvX - MenuConstants.menuMarginSpace - mW - MenuConstants.horizontalMarginSpace)
        
        if leftClippedSpace > 0, rightClippedSpace > 0 {
            
            let diffY = mainViewRect.width - (mW + MenuConstants.menuMarginSpace + tvW + MenuConstants.horizontalMarginSpace + MenuConstants.horizontalMarginSpace)
            if diffY > 0 {
                if (tvX + tvW/2) > mainViewRect.width/2 { //right
                    tvX = tvX + leftClippedSpace
                    mX = tvX - MenuConstants.menuMarginSpace - mW
                }else{ //left
                    tvX = tvX - rightClippedSpace
                    mX = tvX + MenuConstants.menuMarginSpace + tvW
                }
            }else{
                if (tvX + tvW/2) > mainViewRect.width/2 { //right
                    tvX = mainViewRect.width - MenuConstants.horizontalMarginSpace - tvW
                    mX = MenuConstants.horizontalMarginSpace
                }else{ //left
                    tvX = MenuConstants.horizontalMarginSpace
                    mX = tvX + tvW + MenuConstants.menuMarginSpace
                }
            }
        }
        else if rightClippedSpace > 0 {
            mX = tvX - MenuConstants.menuMarginSpace - mW
        }
        else if leftClippedSpace > 0  {
            mX = tvX + MenuConstants.menuMarginSpace  + tvW
        }
        else{
            mX = tvX + MenuConstants.menuMarginSpace + tvW
        }
        
        if mH >= (mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace) {
            mY = MenuConstants.TopMarginSpace
            mH = mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace
        }
        else if (tvY + mH) <= (mainViewRect.height - MenuConstants.BottomMarginSpace) {
            mY = tvY
        }
        else if (tvY + mH) > (mainViewRect.height - MenuConstants.BottomMarginSpace){
            mY = tvY - ((tvY + mH) - (mainViewRect.height - MenuConstants.BottomMarginSpace))
        }
        
        
    }
    
    func updateVerticalTargetedImageViewRect(){
        
        let bottomClippedSpace = (tvH + MenuConstants.menuMarginSpace + mH + tvY + MenuConstants.BottomMarginSpace) - mainViewRect.height
        let topClippedSpace = -(tvY - MenuConstants.menuMarginSpace - mH - MenuConstants.TopMarginSpace)
        
        // not enought space down
        
        if topClippedSpace > 0, bottomClippedSpace > 0 {
            
            let diffY = mainViewRect.height - (mH + MenuConstants.menuMarginSpace + tvH + MenuConstants.TopMarginSpace + MenuConstants.BottomMarginSpace)
            if diffY > 0 {
                if (tvY + tvH/2) > mainViewRect.height/2 { //down
                    tvY = tvY + topClippedSpace
                    mY = tvY - MenuConstants.menuMarginSpace - mH
                }else{ //up
                    tvY = tvY - bottomClippedSpace
                    mY = tvY + MenuConstants.menuMarginSpace + tvH
                }
            } else {
                if (tvY + tvH/2) > mainViewRect.height/2 { //down
                    tvY = mainViewRect.height - MenuConstants.BottomMarginSpace - tvH
                    mY = MenuConstants.TopMarginSpace
                    mH = mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace - MenuConstants.menuMarginSpace - tvH
                } else { //up
                    tvY = MenuConstants.TopMarginSpace
                    mY = tvY + tvH + MenuConstants.menuMarginSpace
                    mH = mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace - MenuConstants.menuMarginSpace - tvH
                }
            }
        }
        else if bottomClippedSpace > 0 {
            mY = tvY - MenuConstants.menuMarginSpace - mH
        } else if topClippedSpace > 0  {
            mY = tvY + MenuConstants.menuMarginSpace  + tvH
        } else {
            mY = tvY + MenuConstants.menuMarginSpace + tvH
        }
        
    }
    
    func updateTargetedImageViewRect(){
        
        self.mainViewRect = self.customView.frame
        
        let targetedImagePosition = getZoomedTargetedSize()
        
        tvH = targetedImagePosition.height
        tvW = targetedImagePosition.width
        tvY = targetedImagePosition.origin.y
        tvX = targetedImagePosition.origin.x
        mH = menuHeight
        mW = MenuConstants.MenuWidth
        mY = tvY + MenuConstants.menuMarginSpace
        mX = max(MenuConstants.menuMarginSpace, tvX)
        if mX + mW >= mainViewRect.width - MenuConstants.menuMarginSpace {
            mX = max(MenuConstants.menuMarginSpace, mainViewRect.width - mW - MenuConstants.menuMarginSpace)
        }
        
        self.fixTargetedImageViewExtrudings()
        
        let backgroundWidth = mainViewRect.width - (2 * MenuConstants.horizontalMarginSpace)
        let backgroundHeight = mainViewRect.height - MenuConstants.TopMarginSpace - MenuConstants.BottomMarginSpace
        
        if backgroundHeight > backgroundWidth {
            self.updateVerticalTargetedImageViewRect()
        } else {
            self.updateHorizontalTargetedImageViewRect()
        }
        
        tableView.frame = CGRect(x: 0, y: 0, width: mW, height: mH)
        tableView.layoutIfNeeded()
        
    }
    
    func updateTargetedImageViewPosition(animated: Bool = true){
        
        self.updateTargetedImageViewRect()
        
        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 6,
                options: [.layoutSubviews, .preferredFramesPerSecond60, .allowUserInteraction],
                animations: { [weak self] in
                    self?.updateTargetedImageViewPositionFrame()
                })
        } else {
            self.updateTargetedImageViewPositionFrame()
        }
    }
    
    func updateTargetedImageViewPositionFrame() {
        let weakSelf = self
        
        weakSelf.menuView.alpha = 1

        weakSelf.menuView.frame = CGRect(
            x: weakSelf.mX,
            y: weakSelf.mY,
            width: weakSelf.mW,
            height: weakSelf.mH
        )
        
        weakSelf.targetedImageView.frame = CGRect(
            x: weakSelf.tvX,
            y: weakSelf.tvY,
            width: weakSelf.tvW,
            height: weakSelf.tvH
        )
        
        weakSelf.blurEffectView.frame = CGRect(
            x: weakSelf.mainViewRect.origin.x,
            y: weakSelf.mainViewRect.origin.y,
            width: weakSelf.mainViewRect.width,
            height: weakSelf.mainViewRect.height
        )
    }
}

extension ContextMenu : UITableViewDataSource, UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContextMenuCell", for: indexPath) as! ContextMenuCell
        cell.contextMenu = self
        cell.tableView = tableView
        cell.style = self.MenuConstants
        cell.item = self.items[indexPath.row]
        cell.setup(isLast: indexPath.row == self.items.count - 1)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        if self.onItemTap?(indexPath.row, item) ?? false {
            self.closeAllViews()
        }
        if self.delegate?.contextMenuDidSelect(self, cell: tableView.cellForRow(at: indexPath) as! ContextMenuCell, targetedView: self.viewTargeted, didSelect: self.items[indexPath.row], forRowAt: indexPath.row) ?? false {
            self.closeAllViews()
        }
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.delegate?.contextMenuDidDeselect(self, cell: tableView.cellForRow(at: indexPath) as! ContextMenuCell, targetedView: self.viewTargeted, didSelect: self.items[indexPath.row], forRowAt: indexPath.row)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == items.count - 1 { return items[indexPath.row].itemHeight }
        let separatorHeight = self.items[indexPath.row].separatorHeight
        return items[indexPath.row].itemHeight + separatorHeight
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == items.count - 1 { return items[indexPath.row].itemHeight }
        let separatorHeight = self.items[indexPath.row].separatorHeight
        return items[indexPath.row].itemHeight + separatorHeight
    }
    
}



@objc class ClosureSleeve: NSObject {
    let closure: () -> Void
    
    init (_ closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func actionHandler(controlEvents control: UIControl.Event = .touchUpInside, ForAction action: @escaping () -> Void) {
        let sleeve = ClosureSleeve(action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: control)
        objc_setAssociatedObject(self, "[\(arc4random())]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
