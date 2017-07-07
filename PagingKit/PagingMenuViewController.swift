//
//  PagingMenuViewController.swift
//  PagingViewController
//
//  Created by Kazuhiro Hayashi on 7/2/17.
//  Copyright © 2017 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public protocol PagingMenuViewControllerScrollDelegate: class {
    func menuViewController(viewController: PagingMenuViewController,  focusViewDidEndTransition focusView: PagingMenuFocusView)
}

extension PagingMenuViewControllerScrollDelegate {
    public func menuViewController(viewController: PagingMenuViewController,  focusViewDidEndTransition focusView: PagingMenuFocusView) {}
}

public protocol PagingMenuViewControllerDelegate: class {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int)
}

public protocol PagingMenuViewControllerDataSource: class {
    func numberOfItemForMenuViewController(viewController: PagingMenuViewController) -> Int
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> UICollectionViewCell
    func menuViewController(viewController: PagingMenuViewController, areaForItemAt index: Int) -> CGFloat
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
    public enum Direction {
        case horizontal
        case vertical
    }
    
    public weak var scrollDelegate: PagingMenuViewControllerScrollDelegate?
    public weak var delegate: PagingMenuViewControllerDelegate?
    public weak var dataSource: PagingMenuViewControllerDataSource?
    
    public var focusView = PagingMenuFocusView(frame: .zero)
    
    public var focusPointerOffset: CGPoint {
        return focusView.center
    }
    public var direction: Direction {
        switch layout.scrollDirection {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
    public var percentOffset: CGFloat {
        switch layout.scrollDirection {
        case .horizontal:
            return collectionView.contentOffset.x / collectionView.contentSize.width
        default:
            return collectionView.contentOffset.y / collectionView.contentSize.height
        }
    }
    
    public func scroll(index: Int, percent: CGFloat = 0, animated: Bool = true) {
        let rightIndex = index + 1
        guard rightIndex < collectionView.numberOfItems(inSection: 0),
            let leftAttribute = collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)),
            let rightAttribute = collectionView.layoutAttributesForItem(at: IndexPath(item: rightIndex, section: 0)) else { return }
        
        let width = (rightAttribute.frame.width - leftAttribute.frame.width) * percent + leftAttribute.frame.width
        let height = (rightAttribute.frame.height - leftAttribute.frame.height) * percent + leftAttribute.frame.height
        focusView.frame.size = CGSize(width: width, height: height)
        
        let centerPointX = leftAttribute.center.x + (rightAttribute.center.x - leftAttribute.center.x) * percent
        let offsetX = centerPointX - collectionView.bounds.width / 2
        let maxOffsetX = max(0, collectionView.contentSize.width - collectionView.bounds.width)
        let normaizedOffsetX = min(max(0, offsetX), maxOffsetX)
        
        let centerPointY = leftAttribute.center.y + (rightAttribute.center.y - leftAttribute.center.y) * percent
        let offsetY = centerPointY - collectionView.bounds.height / 2
        let maxOffsetY = max(0, collectionView.contentSize.height - collectionView.bounds.height)
        let normaizedOffsetY = min(max(0, offsetY), maxOffsetY)
        let offset = CGPoint(x: normaizedOffsetX, y:normaizedOffsetY)
        
        focusView.center = CGPoint(x: centerPointX, y: centerPointY)
        
        collectionView.setContentOffset(offset, animated: animated)
        focusView.selectedIndex = index
        
        if percent == 0 && !animated {
            scrollDelegate?.menuViewController(viewController: self, focusViewDidEndTransition: focusView)
        }
    }
    
    public var visibleCells: [UICollectionViewCell] {
        return collectionView.visibleCells
    }
    
    public var currentFocusedCell: UICollectionViewCell? {
        return collectionView.indexPathForItem(at: focusView.center).flatMap(collectionView.cellForItem)
    }
    
    public var currentFocusedIndex: Int? {
        return collectionView.indexPathForItem(at: focusView.center)?.row
    }
    
    public func cellForItem(at index: Int) -> UICollectionViewCell? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    public func registerFocusView(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth, .flexibleHeight]
        view.frame = focusView.bounds
        focusView.addSubview(view)
    }
    
    public func registerFocusView(nib: UINib) {
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        registerFocusView(view: view)
    }
    
    public func register(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0))
    }
    
    public func reloadDate(startingOn index: Int? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        collectionView.reloadData()
        
        if let index = index {
            collectionView.performBatchUpdates(nil) { [weak self] (finish) in
                guard let _self = self else { return }
                _self.scroll(index: index, percent: 0, animated: false)
                completionHandler?(finish)
            }
        }
    }
    
    fileprivate let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.frame = view.bounds
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        
        view.backgroundColor = .clear
        
        focusView.translatesAutoresizingMaskIntoConstraints = true
        focusView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        focusView.frame = collectionView.bounds
        collectionView.addSubview(focusView)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHandler?()
    }
    
    var layoutHandler: (() -> Void)?
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let indexPath = collectionView.indexPathForItem(at: focusView.center)
        layoutHandler = { [weak self] in
            self?.collectionView.invalidateIntrinsicContentSize()
            self?.scroll(index: indexPath?.row ?? 0, percent: 0, animated: false)
            self?.layoutHandler = nil
        }
    }
}

extension PagingMenuViewController: UICollectionViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.menuViewController(viewController: self, focusViewDidEndTransition: focusView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollDelegate?.menuViewController(viewController: self, focusViewDidEndTransition: focusView)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let attribute = collectionView.layoutAttributesForItem(at: indexPath) else { return }

        delegate?.menuViewController(viewController: self, didSelect: indexPath.row, previousPage: focusView.selectedIndex ?? 0)
    
        focusView.selectedIndex = indexPath.item
        
        let offset: CGPoint
        switch direction {
        case .horizontal:
            let offsetX = attribute.center.x - collectionView.bounds.width / 2
            let maxOffsetX = collectionView.contentSize.width - collectionView.bounds.width
            offset = CGPoint(x: min(max(0, offsetX), maxOffsetX), y: 0)
        case .vertical:
            let offsetY = attribute.center.y - collectionView.bounds.height / 2
            let maxOffsetY = collectionView.contentSize.height - collectionView.bounds.height
            offset = CGPoint(x: 0, y: min(max(0, offsetY), maxOffsetY))
        }
        collectionView.setContentOffset(offset, animated: true)

        UIView.perform(.delete, on: [], options: UIViewAnimationOptions(rawValue: 0), animations: { [weak self] in
            self?.focusView.frame = attribute.frame
            }, completion: { [weak self] finish in
                guard let _self = self, finish else { return }
                _self.scrollDelegate?.menuViewController(viewController: _self, focusViewDidEndTransition: _self.focusView)
        })
    }
}

extension PagingMenuViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemForMenuViewController(viewController: self) ?? 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.menuViewController(viewController: self, cellForItemAt: indexPath.row)
    }
}

extension PagingMenuViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let area = dataSource?.menuViewController(viewController: self, areaForItemAt: indexPath.row) ?? 0
        switch direction {
        case .horizontal:
            return CGSize(width: area, height: collectionView.bounds.height)
        case .vertical:
            return CGSize(width: area, height: collectionView.bounds.height)
        }
    }
}
