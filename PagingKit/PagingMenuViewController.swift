//
//  PagingMenuViewController.swift
//  PagingKit
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/// this represents the display and behaviour of the cells.
public protocol PagingMenuViewControllerDelegate: class {
    
    /// Tells the delegate when the menu finished to scroll focus view.
    ///
    /// - Parameters:
    ///   - viewController: A menu view controller object that finished to scroll focus view.
    ///   - focusView: the view that a menu view controller is using to focus current page of menu.
    func menuViewController(viewController: PagingMenuViewController, focusViewDidEndTransition focusView: PagingMenuFocusView)
    
    /// Tells the delegate that the specified page is now selected.
    ///
    /// - Parameters:
    ///   - viewController: A menu view controller object informing the delegate about the new page selection.
    ///   - page: An page number focusing the new selected menu in menu view controller.
    ///   - previousPage: An page number previously focusing menu in menu view controller.
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int)
}

extension PagingMenuViewControllerDelegate {
    public func menuViewController(viewController: PagingMenuViewController, focusViewDidEndTransition focusView: PagingMenuFocusView) {}
}

/// The data source provides the paging menu view controller object with the information it needs to construct and modify the menus.
public protocol PagingMenuViewControllerDataSource: class {
    
    /// Tells the data source to return the number of items in a menu view of the menu view controller.
    ///
    /// - Parameter viewController: The menu view controller object requesting this information.
    /// - Returns: The number of items.
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int
    
    /// Asks the data source for a cell to insert in a particular location of the menu view of menu view controller.
    ///
    /// - Parameters:
    ///   - viewController: A menu view controller object requesting the cell.
    ///   - index: An index locating a items in menu view controller.
    /// - Returns: An object inheriting from PagingMenuViewCell that the menu view controller can use for the specified item.
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell
    
    /// Asks the delegate for the width to use for a cell in a specified location.
    ///
    /// - Parameters:
    ///   - viewController: The menu view controller object requesting this information.
    ///   - index: An index  that locates a menu in menu view.
    /// - Returns: A nonnegative floating-point value that specifies the width (in points) that cell should be.
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat
}

/// A view that focus menu corresponding to current page.
public class PagingMenuFocusView: UIView {
    var selectedIndex: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/// A view controller that presents menu using cells arranged in a single column.
public class PagingMenuViewController: UIViewController {
    /// The object that acts as the delegate of the menu view controller.
    public weak var delegate: PagingMenuViewControllerDelegate?
    /// The object that acts as the data source of the menu view controller.
    public weak var dataSource: PagingMenuViewControllerDataSource?

    /// The object that acts as the indicator to focus current menu.
    public let focusView = PagingMenuFocusView(frame: .zero)

    /// The object to show data and tap interaction.
    public let menuView: PagingMenuView = {
        let view = PagingMenuView(frame: .zero)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The point at which the origin of the focus view is offset from the origin of the scroll view.
    public var focusPointerOffset: CGPoint {
        return focusView.center
    }

    /// The rate at which the origin of the focus view is offset from the origin of the scroll view.
    public var percentOffset: CGFloat {
        return menuView.contentOffset.x / menuView.contentSize.width
    }
    
    /// The spacing to use between menus.
    public var cellSpacing: CGFloat {
        set {
            menuView.cellSpacing = newValue
        }
        get {
            return menuView.cellSpacing
        }
    }

    /// Scrolls a specific index of the menu so that it is visible in the receiver.
    ///
    /// - Parameters:
    ///   - index: A index defining an menu of the menu view.
    ///   - percent: A rate that transit from the index.
    ///   - animated: true if the scrolling should be animated, false if it should be immediate.
    public func scroll(index: Int, percent: CGFloat = 0, animated: Bool = true) {
        let rightIndex = index + 1

        guard let leftFrame = menuView.rectForItem(at: index),
            let rightFrame = menuView.rectForItem(at: rightIndex) else { return }
        
        let width = (rightFrame.width - leftFrame.width) * percent + leftFrame.width
        focusView.frame.size = CGSize(width: width, height: menuView.bounds.height)
        
        let centerPointX = leftFrame.midX + (rightFrame.midX - leftFrame.midX) * percent
        let offsetX = centerPointX - menuView.bounds.width / 2
        let maxOffsetX = max(0, menuView.contentSize.width - menuView.bounds.width)
        let normaizedOffsetX = min(max(0, offsetX), maxOffsetX)
        focusView.center = CGPoint(x: centerPointX, y: menuView.center.y)

        menuView.setContentOffset(CGPoint(x: normaizedOffsetX, y:0), animated: animated)
        focusView.selectedIndex = index
        
        if percent == 0 && !animated {
            delegate?.menuViewController(viewController: self, focusViewDidEndTransition: focusView)
        }
    }

    /// Returns an array of visible cells currently displayed by the menu view.
    public var visibleCells: [PagingMenuViewCell] {
        return menuView.visibleCells
    }

    /// Returns the menu cell that the view controller is focusing.
    public var currentFocusedCell: PagingMenuViewCell? {
        return focusView.selectedIndex.flatMap(menuView.cellForItem)
    }

    /// Returns the index that the view controller is focusing.
    public var currentFocusedIndex: Int? {
        return focusView.selectedIndex
    }

    /// Returns the menu cell at the specified index.
    ///
    /// - Parameter index: The index locating the item in the menu view.
    /// - Returns: An object representing a cell of the menu, or nil if the cell is not visible or index is out of range.
    public func cellForItem(at index: Int) -> PagingMenuViewCell? {
        return menuView.cellForItem(at: index)
    }

    /// Registers a view that a menu view controller uses to focus each menu.
    ///
    /// - Parameters:
    ///   - view: A view object to use focus view.
    ///   - isBehindCell: the focus view is placed behind the menus of menu view controller.
    public func registerFocusView(view: UIView, isBehindCell: Bool = false) {
        focusView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        focusView.addConstraints([.top, .bottom, .leading, .trailing].map {
            NSLayoutConstraint(item: view, attribute: $0, relatedBy: .equal, toItem: focusView, attribute: $0, multiplier: 1, constant: 0)
        })
        focusView.layer.zPosition = isBehindCell ? -1 : 0
    }

    /// Registers a nib that a menu view controller uses to focus each menu.
    ///
    /// - Parameters:
    ///   - view: A nib object to use focus view.
    ///   - isBehindCell: the focus view is placed behind the menus of menu view controller.
    public func registerFocusView(nib: UINib, isBehindCell: Bool = false) {
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        registerFocusView(view: view, isBehindCell: isBehindCell)
    }
    
    /// Registers a nib object containing a cell with the menu view controller under a specified identifier.
    ///
    /// - Parameters:
    ///   - nib: A nib object that specifies the nib file to use to create the cell.
    ///   - identifier: The reuse identifier for the cell. This parameter must not be nil and must not be an empty string.
    public func register(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        menuView.register(nib: nib, with: identifier)
    }

    /// Returns a reusable menu view cell object for the specified reuse identifier and adds it to the menu.
    ///
    /// - Parameters:
    ///   - identifier: A string identifying the cell object to be reused. This parameter must not be nil.
    ///   - index: The index specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index to perform additional configuration based on the cell’s position in the menu view controller.
    /// - Returns: A PagingMenuViewCell object with the associated reuse identifier. This method always returns a valid cell.
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> PagingMenuViewCell {
        return menuView.dequeue(with: identifier)
    }

    /// Reloads the items of the menu view controller.
    ///
    /// - Parameters:
    ///   - preferredFocusIndex: A preferred index to focus after reloading.
    ///   - completionHandler: The block to execute after the reloading finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
    public func reloadData(with preferredFocusIndex: Int? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        let selectedIndex = preferredFocusIndex ?? currentFocusedIndex ?? 0
        focusView.selectedIndex = selectedIndex
        UIView.animate(
            withDuration: 0,
            animations: { [weak self] in
                self?.menuView.reloadData()
            },
            completion: {  [weak self] (finish) in
                guard let _self = self else { return }
                let scrollIndex = selectedIndex
                _self.scroll(index: scrollIndex, percent: 0, animated: false)
                completionHandler?(finish)
            }
        )
    }

    /// Invalidates the current layout using the information in the provided context object.
    public func invalidateLayout() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        menuView.invalidateLayout()
        if let selectedIndex = focusView.selectedIndex {
            scroll(index: selectedIndex, percent: 0, animated: false)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let view = object as? UIView, view == self.view, keyPath == #keyPath(UIView.frame) {
            invalidateLayout()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.menuDelegate = self
        menuView.delegate = self
        menuView.dataSource = self

        view.addSubview(menuView)
        view.addConstraints([.top, .bottom, .leading, .trailing].map {
            NSLayoutConstraint(item: menuView, attribute: $0, relatedBy: .equal, toItem: view, attribute: $0, multiplier: 1, constant: 0)
        })

        view.addObserver(self, forKeyPath: #keyPath(UIView.frame), options: [.old, .new], context: nil)
        
        focusView.frame = .zero
        menuView.addSubview(focusView)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        view.removeObserver(self, forKeyPath: #keyPath(UIView.frame))
    }
}

// MARK:- UIScrollViewDelegate

extension PagingMenuViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.menuViewController(viewController: self, focusViewDidEndTransition: focusView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            delegate?.menuViewController(viewController: self, focusViewDidEndTransition: focusView)
        }
    }
}

// MARK:- PagingMenuViewDelegate

extension PagingMenuViewController: PagingMenuViewDelegate {
    public func pagingMenuView(pagingMenuView: PagingMenuView, didSelectItemAt index: Int) {
        guard let itemFrame = pagingMenuView.rectForItem(at: index), focusView.selectedIndex != index else { return }
        
        delegate?.menuViewController(viewController: self, didSelect: index, previousPage: focusView.selectedIndex ?? 0)
        
        focusView.selectedIndex = index
        
        let offset: CGPoint
        let offsetX = itemFrame.midX - menuView.bounds.width / 2
        let maxOffsetX = max(menuView.bounds.width, menuView.contentSize.width) - menuView.bounds.width
        offset = CGPoint(x: min(max(0, offsetX), maxOffsetX), y: 0)
        
        UIView.perform(.delete, on: [], options: UIViewAnimationOptions(rawValue: 0), animations: { [weak self] in
            self?.menuView.contentOffset = offset
            self?.focusView.frame = itemFrame
            self?.focusView.layoutIfNeeded()
            }, completion: { [weak self] finish in
                guard let _self = self, finish else { return }
                _self.delegate?.menuViewController(viewController: _self, focusViewDidEndTransition: _self.focusView)
        })
    }
}

// MARK:- PagingMenuViewDataSource

extension PagingMenuViewController: PagingMenuViewDataSource {
    public func numberOfItemForPagingMenuView() -> Int {
        return dataSource?.numberOfItemsForMenuViewController(viewController: self) ?? 0
    }
    
    public func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat {
        let area = dataSource?.menuViewController(viewController: self, widthForItemAt: index) ?? 0
        return area
    }

    public func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuViewCell {
        return dataSource!.menuViewController(viewController: self, cellForItemAt: index)
    }
}


