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
    func numberOfItemForMenuViewController(viewController: PagingMenuViewController) -> Int
    
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

public class PagingMenuViewController: UIViewController {
    public weak var delegate: PagingMenuViewControllerDelegate?
    public weak var dataSource: PagingMenuViewControllerDataSource?
    
    fileprivate var focusView = PagingMenuFocusView(frame: .zero)
    
    public var focusPointerOffset: CGPoint {
        return focusView.center
    }

    public var percentOffset: CGFloat {
        return menuView.contentOffset.x / menuView.contentSize.width
    }
    
    
    /// space setting between cells
    public var cellSpacing: CGFloat {
        set {
            menuView.cellSpacing = newValue
        }
        get {
            return menuView.cellSpacing
        }
    }
    
    public func scroll(index: Int, percent: CGFloat = 0, animated: Bool = true) {
        let rightIndex = index + 1

        guard let leftFrame = menuView.rectForItem(at: index),
            let rightFrame = menuView.rectForItem(at: rightIndex) else { return }
        
        let width = (rightFrame.width - leftFrame.width) * percent + leftFrame.width
        let height = (rightFrame.height - leftFrame.height) * percent + leftFrame.height
        focusView.frame.size = CGSize(width: width, height: height)
        
        let centerPointX = leftFrame.midX + (rightFrame.midX - leftFrame.midX) * percent
        let offsetX = centerPointX - menuView.bounds.width / 2
        let maxOffsetX = max(0, menuView.contentSize.width - menuView.bounds.width)
        let normaizedOffsetX = min(max(0, offsetX), maxOffsetX)
        
        let centerPointY = leftFrame.midY + (rightFrame.midY - leftFrame.midY) * percent
        let offsetY = centerPointY - menuView.bounds.height / 2
        let maxOffsetY = max(0, menuView.contentSize.height - menuView.bounds.height)
        let normaizedOffsetY = min(max(0, offsetY), maxOffsetY)
        let offset = CGPoint(x: normaizedOffsetX, y:normaizedOffsetY)
        
        focusView.center = CGPoint(x: centerPointX, y: centerPointY)
        
        menuView.setContentOffset(offset, animated: animated)
        focusView.selectedIndex = index
        
        if percent == 0 && !animated {
            delegate?.menuViewController(viewController: self, focusViewDidEndTransition: focusView)
        }
    }
    
    public var visibleCells: [PagingMenuViewCell] {
        return menuView.visibleCells
    }
    
    public var currentFocusedCell: PagingMenuViewCell? {
        return focusView.selectedIndex.flatMap(menuView.cellForItem)
    }
    
    public var currentFocusedIndex: Int? {
        return focusView.selectedIndex
    }
    
    public func cellForItem(at index: Int) -> PagingMenuViewCell? {
        return menuView.cellForItem(at: index)
    }
    
    public func registerFocusView(view: UIView, isBehindCell: Bool = false) {
        focusView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        focusView.addConstraints([.top, .bottom, .leading, .trailing].map {
            NSLayoutConstraint(item: view, attribute: $0, relatedBy: .equal, toItem: focusView, attribute: $0, multiplier: 1, constant: 0)
        })
        focusView.layer.zPosition = isBehindCell ? -1 : 0
    }
    
    public func registerFocusView(nib: UINib, isBehindCell: Bool = false) {
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        registerFocusView(view: view, isBehindCell: isBehindCell)
    }
    
    public func register(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        menuView.register(nib: nib, with: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> PagingMenuViewCell {
        return menuView.dequeue(with: identifier)
    }
    
    public func reloadData(with preferredFocusIndex: Int? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: 0,
            animations: { [weak self] in
                self?.menuView.reloadData()
            },
            completion: {  [currentFocusedIndex = currentFocusedIndex, weak self] (finish) in
                guard let _self = self else { return }
                let scrollIndex = preferredFocusIndex ?? currentFocusedIndex ?? 0
                _self.scroll(index: scrollIndex, percent: 0, animated: false)
                completionHandler?(finish)
            }
        )
    }
    
    public func invalidateLayout() {
        menuView.invalidateLayout()
        scroll(index: focusView.selectedIndex ?? 0, percent: 0, animated: false)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let view = object as? UIView, view == self.view, keyPath == #keyPath(UIView.frame) {
            invalidateLayout()
        }
    }

    fileprivate var menuView: PagingMenuView = {
        let view = PagingMenuView(frame: .zero)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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

extension PagingMenuViewController: PagingMenuViewDataSource {
    public func numberOfItemForPagingMenuView() -> Int {
        return dataSource?.numberOfItemForMenuViewController(viewController: self) ?? 0
    }
    
    public func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat {
        let area = dataSource?.menuViewController(viewController: self, widthForItemAt: index) ?? 0
        return area
    }

    public func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuViewCell {
        return dataSource!.menuViewController(viewController: self, cellForItemAt: index)
    }
}


