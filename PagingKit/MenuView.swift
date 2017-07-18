//
//  MenuView.swift
//  PagingKit
//
//  Created by Kazuhiro Hayashi on 2017/07/11.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

open class PagingMenuViewCell: UIView {
    open var isSelected: Bool = false
    public internal(set) var identifier: String!
    public internal(set) var index: Int!
}

public protocol PagingMenuViewDataSource: class {
    func numberOfItemForPagingMenuView() -> Int
    func pagingMenuView(pagingMenuView: PagingMenuView, cellForItemAt index: Int) -> PagingMenuViewCell
    func pagingMenuView(pagingMenuView: PagingMenuView, widthForItemAt index: Int) -> CGFloat
}

public protocol PagingMenuViewDelegate: UIScrollViewDelegate {
    func pagingMenuView(pagingMenuView: PagingMenuView, didSelectItemAt index: Int)
}

public class PagingMenuView: UIScrollView {
    public fileprivate(set) var visibleCells = [PagingMenuViewCell]()

    fileprivate var queue = [String: [PagingMenuViewCell]]()
    fileprivate var nibs = [String: UINib]()
    fileprivate var frameQueue = [CGRect]()
    fileprivate var containerView = UIView()
    
    public weak var dataSource: PagingMenuViewDataSource?
    
    private weak var _delegate: PagingMenuViewDelegate?
    public override var delegate: UIScrollViewDelegate? {
        didSet {
            _delegate = delegate as? PagingMenuViewDelegate
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.frame = bounds
        containerView.center = center
        
        addSubview(containerView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        containerView.frame = bounds
        containerView.center = center
        
        addSubview(containerView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        if numberOfItem != 0 {
            let visibleBounds = convert(bounds, to: containerView)
            tileCell(
                from: max(0, visibleBounds.minX),
                to: min(contentSize.width, visibleBounds.maxX)
            )
        }
    }
    
    var numberOfItem: Int = 0
    
    public func indexForItem(at point: CGPoint) -> Int? {
        return frameQueue.enumerated().filter { $1.contains(point) }.flatMap{ $0.offset }.first
    }
    
    
    public func cellForItem(at index: Int) -> PagingMenuViewCell? {
        return visibleCells.filter { $0.index == index }.first
    }
    
    public func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        visibleCells.forEach { $0.removeFromSuperview() }
        visibleCells = []
        
        numberOfItem = dataSource.numberOfItemForPagingMenuView()
        
        frameQueue = []
        var containerWidth: CGFloat = 0
        (0..<numberOfItem).forEach { (index) in
            let width = dataSource.pagingMenuView(pagingMenuView: self, widthForItemAt: index)
            frameQueue.append(CGRect(x: containerWidth, y: 0, width: width, height: bounds.height))
            containerWidth += width
        }
        contentSize = CGSize(width: containerWidth, height: bounds.height)
        containerView.frame = CGRect(origin: .zero, size: contentSize)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func register(nib: UINib?, with identifier: String) {
        nibs[identifier] = nib
    }
    
    public func dequeue(with identifier: String) -> PagingMenuViewCell {
        if var cells = queue[identifier], !cells.isEmpty {
            let cell = cells.removeFirst()
            queue[identifier] = cells
            cell.identifier = identifier
            return cell
        }
        
        if let nib = nibs[identifier] {
            let cell = nib.instantiate(withOwner: self, options: nil).first as! PagingMenuViewCell
            cell.identifier = identifier
            return cell
        }
        
        fatalError()
    }
    
    public func rectForItem(at index: Int) -> CGRect? {
        guard index < frameQueue.count else {
            let lastFrame = frameQueue.last
            let rightEdge = lastFrame.flatMap { CGRect(x: $0.maxX, y: 0, width: 0, height: 0) }
            return rightEdge
        }
        
        let x = (0..<index).reduce(0) { (sum, idx) in
            return sum + frameQueue[idx].width
        }
        return CGRect(x: x, y: 0, width: frameQueue[index].width, height: bounds.height)
    }
    
    private func recenterIfNeeded() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let centerOffsetX = (contentWidth - bounds.size.width) / 2
        let distanceFromCenter = fabs(currentOffset.x - centerOffsetX)
        
        if distanceFromCenter > (contentWidth - bounds.size.width) / 4 {
            contentOffset = CGPoint(x: centerOffsetX, y: currentOffset.y)
            
            for cell in visibleCells {
                var center = containerView.convert(cell.center, to: self)
                center.x += centerOffsetX - currentOffset.x
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    private func align() {
        visibleCells.forEach { (cell) in
            let leftEdge = (0..<cell.index).reduce(CGFloat(0)) { (sum, idx) in sum + frameQueue[idx].width }
            cell.frame.origin.x = leftEdge
        }
    }
    
    @discardableResult
    private func placeNewCellOnRight(with rightEdge: CGFloat, index: Int, dataSource: PagingMenuViewDataSource) -> CGFloat {
        let nextIndex = (index + 1) % numberOfItem
        let cell = dataSource.pagingMenuView(pagingMenuView: self, cellForItemAt: nextIndex)
        cell.index = nextIndex
        containerView.addSubview(cell)
        
        visibleCells.append(cell)
        cell.frame.origin = CGPoint(x: rightEdge, y: 0)
        cell.frame.size = CGSize(width: frameQueue[nextIndex].width, height: bounds.height)

        return cell.frame.maxX
    }
    
    private func placeNewCellOnLeft(with leftEdge: CGFloat, index: Int, dataSource: PagingMenuViewDataSource) -> CGFloat {
        let nextIndex: Int
        if index == 0 {
            nextIndex = numberOfItem - 1
        } else {
            nextIndex = (index - 1) % numberOfItem
        }
        let cell = dataSource.pagingMenuView(pagingMenuView: self, cellForItemAt: nextIndex)
        cell.index = nextIndex
        
        containerView.addSubview(cell)
        
        visibleCells.insert(cell, at: 0)
        cell.frame.size = CGSize(width: frameQueue[nextIndex].width, height: bounds.height)
        cell.frame.origin = CGPoint(x: leftEdge - frameQueue[nextIndex].width, y: 0)
        return cell.frame.minX
    }
    
    private func tileCell(from minX: CGFloat, to maxX: CGFloat) {
        guard let dataSource = dataSource, 0 < numberOfItem else {
            return
        }
        
        if visibleCells.isEmpty {
            placeNewCellOnRight(with: minX, index: numberOfItem - 1, dataSource: dataSource)
        }
        
        var lastCell = visibleCells.last
        var rightEdge = lastCell?.frame.maxX
        while let _lastCell = lastCell, let _rightEdge = rightEdge,
            _rightEdge < maxX, (0..<numberOfItem) ~= _lastCell.index + 1 {
                rightEdge = placeNewCellOnRight(with: _rightEdge, index: _lastCell.index, dataSource: dataSource)
                lastCell = visibleCells.last
        }
        
        var firstCell = visibleCells.first
        var leftEdge = firstCell?.frame.minX
        while let _firstCell = firstCell, let _leftEdge = leftEdge,
            _leftEdge > minX, (0..<numberOfItem) ~= _firstCell.index - 1 {
                leftEdge = placeNewCellOnLeft(with: _leftEdge, index: _firstCell.index, dataSource: dataSource)
                firstCell = visibleCells.first
        }
        
        
        while let lastCell = visibleCells.last, lastCell.frame.minX > maxX {
            lastCell.removeFromSuperview()
            let recycleCell = visibleCells.removeLast()
            
            if let cells = queue[recycleCell.identifier] {
                queue[recycleCell.identifier] = cells + [recycleCell]
            } else {
                queue[recycleCell.identifier] = [recycleCell]
            }
        }

        while let firstCell = visibleCells.first, firstCell.frame.maxX < minX {
            firstCell.removeFromSuperview()
            let recycleCell = visibleCells.removeFirst()
            
            if let cells = queue[recycleCell.identifier] {
                queue[recycleCell.identifier] = cells + [recycleCell]
            } else {
                queue[recycleCell.identifier] = [recycleCell]
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let selectedCell = touches.first.flatMap { $0.location(in: self) }.flatMap { hitTest($0, with: event) as? PagingMenuViewCell }
        if let index = selectedCell?.index {
            _delegate?.pagingMenuView(pagingMenuView: self, didSelectItemAt: index)
        }
    }
}
