//
//  PagingMenuViewController.swift
//  PagingViewController
//
//  Created by Kazuhiro Hayashi on 7/2/17.
//  Copyright © 2017 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public protocol PagingMenuViewControllerDelegate: class {
    func menuViewController(viewController: PagingMenuViewController,  focusViewDidEndTransition focusView: PagingMenuFocusView)
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int)
}

extension PagingMenuViewControllerDelegate {
    public func menuViewController(viewController: PagingMenuViewController,  focusViewDidEndTransition focusView: PagingMenuFocusView) {}
}

public protocol PagingMenuViewControllerDataSource: class {
    func numberOfItemForMenuViewController(viewController: PagingMenuViewController) -> Int
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell
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

    public var percentOffset: CGFloat {
        return menuView.contentOffset.x / menuView.contentSize.width
    }
    
    public func scroll(index: Int, percent: CGFloat = 0, animated: Bool = true) {
        if animated {
            UIView.perform(.delete, on: [], options: UIViewAnimationOptions(rawValue: 0), animations: { [weak self] in
                self?.menuView.scroll(index: index, percent: percent)
            }, completion: { [weak self] finish in
                guard let _self = self, finish, percent == 0 else { return }
                _self.delegate?.menuViewController(viewController: _self, focusViewDidEndTransition: _self.menuView.focusView)
            })
        } else {
            menuView.scroll(index: index, percent: percent)
            if percent == 0 {
                delegate?.menuViewController(viewController: self, focusViewDidEndTransition: menuView.focusView)
            }
        }
    }
    
    public var visibleCells: [PagingMenuViewCell] {
        return menuView.visibleCells
    }
    
    public var currentFocusedCell: PagingMenuViewCell? {
        return menuView.focusView.selectedIndex.flatMap(menuView.cellForItem)
    }
    
    public var currentFocusedIndex: Int? {
        return menuView.focusView.selectedIndex
    }
    
    public func cellForItem(at index: Int) -> PagingMenuViewCell? {
        return menuView.cellForItem(at: index)
    }
    
    public func registerFocusView(view: UIView, isBehindCell: Bool = false) {
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth, .flexibleHeight]
        view.frame = menuView.focusView.bounds
        menuView.focusView.addSubview(view)
        menuView.focusView.layer.zPosition = isBehindCell ? -1 : 0
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
    
    public func reloadData(startingOn index: Int? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: 0,
            animations: { [weak self] in
                self?.menuView.reloadData()
            },
            completion: {  [weak self] (finish) in
                if let index = index {
                    guard let _self = self else { return }
                    _self.scroll(index: index, percent: 0, animated: false)
                    completionHandler?(finish)
                }
            }
        )
    }
    
    fileprivate var menuView: PagingMenuView = {
        let view = PagingMenuView(frame: .zero)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.menuDelegate = self
        menuView.dataSource = self

        menuView.frame = view.bounds
        menuView.focusView.frame = menuView.bounds
        view.addSubview(menuView)
        
        view.backgroundColor = .clear
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHandler?()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutHandler = nil
    }
    
    var layoutHandler: (() -> Void)?
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        layoutHandler = { [weak self] in
            self?.menuView.invalidateLayout()
            self?.scroll(index: self?.menuView.focusView.selectedIndex ?? 0, percent: 0, animated: false)
            self?.layoutHandler = nil
        }
    }
}

extension PagingMenuViewController: PagingMenuViewDelegate {
    public func pagingMenuView(pagingMenuView: PagingMenuView, didSelectItemAt index: Int) {
        delegate?.menuViewController(viewController: self, didSelect: index, previousPage: menuView.focusView.selectedIndex ?? 0)
        
        UIView.perform(.delete, on: [], options: UIViewAnimationOptions(rawValue: 0), animations: { [weak self] in
            self?.menuView.scroll(index: index, percent: 0)
            }, completion: { [weak self] finish in
                guard let _self = self, finish else { return }
                _self.delegate?.menuViewController(viewController: _self, focusViewDidEndTransition: _self.menuView.focusView)
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


