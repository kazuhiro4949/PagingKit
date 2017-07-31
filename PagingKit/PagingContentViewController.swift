//
//  PagingContentViewController.swift
//  PagingViewController
//
//  Created by Kazuhiro Hayashi on 7/2/17.
//  Copyright © 2017 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public protocol PagingContentViewControllerDelegate: class {
    func contentViewController(viewController: PagingContentViewController, willBeginManualScrollOn index: Int)
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat)
    func contentViewController(viewController: PagingContentViewController, willEndManualScrollOn index: Int)
    func contentViewController(viewController: PagingContentViewController, didEndManualScrollOn index: Int)
}

extension PagingContentViewControllerDelegate {
    public func contentViewController(viewController: PagingContentViewController, willBeginManualScrollOn index: Int) {}
    public func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {}
    public func contentViewController(viewController: PagingContentViewController, didEndManualScrollOn index: Int) {}
}

public protocol PagingContentViewControllerDataSource: class {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController
}

public class PagingContentViewController: UIViewController {
    
    typealias Content = (index: Int, vc: UIViewController)
    
    fileprivate var visibleViewControllers = [Content]()
    
    public weak var delegate: PagingContentViewControllerDelegate?
    public weak var dataSource: PagingContentViewControllerDataSource?

    public var isEnabledPreloadContent = true
    
    public fileprivate(set) var pageIndex: Int = 0
    
    public var contentOffsetRatio: CGFloat {
        return scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width)
    }

    public var pagingPercent: CGFloat {
        return scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) / scrollView.bounds.width
    }
    
    public var currentPageIndex: Int {
        return Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    public func reloadData(with page: Int = 0) {
        removeAll()
        
        UIView.animate(
            withDuration: 0,
            animations: { [weak self] in
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self] (finish) in
                guard let _self = self else { return }
                _self.initialLoad(with: page)
//                self?.scroll(to: page, animated: false)
            }
        )
    }
    
    public func scroll(to page: Int, animated: Bool) {
//        let offsetX = scrollView.bounds.width * CGFloat(page)
//        loadPagesIfNeeded(page: page)
//        if animated {
//            performSystemAnimation({ [weak self] in
//                self?.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
//            })
//        } else {
//            scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
//        }
    }
    
    fileprivate var numberOfPages: Int = 0
    
    fileprivate var isExplicityScrolling = false
    
    fileprivate let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        view.backgroundColor = .clear
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recenterIfNeeded()
        
        tileChildViewControllers(from: 0, to: scrollView.contentSize.width)
        
        layoutCompletionHandler?()
    }
    
    func recenterIfNeeded() {
        let currentOffset = scrollView.contentOffset
        let contentWidth = scrollView.contentSize.width
        let centerOffsetX = scrollView.bounds.size.width * 2
        let distanceFromCenter = currentOffset.x - centerOffsetX
        
        if fabs(distanceFromCenter) > scrollView.bounds.size.width {
            scrollView.contentOffset.x = centerOffsetX
            let shiftingOffsetX = distanceFromCenter > 0 ? -scrollView.bounds.size.width : scrollView.bounds.size.width
            visibleViewControllers.forEach { (content) in
                content.vc.view.center.x += shiftingOffsetX
            }
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var layoutCompletionHandler: (() -> Void)?
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        removeAll()
        
        let leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        layoutCompletionHandler = { [weak self] in
            guard let _self = self else { return }
            _self.initialLoad(with: leftSidePageIndex)
            _self.scroll(to: leftSidePageIndex, animated: false)
            _self.layoutCompletionHandler = nil
        }
    }
    
    fileprivate func removeAll() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        childViewControllers.forEach { $0.removeFromParentViewController() }
    }
    
    fileprivate func initialLoad(with page: Int) {
        removeAll()
        numberOfPages = dataSource?.numberOfItemForContentViewController(viewController: self) ?? 0
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.size.width * CGFloat(min(5, numberOfPages)),
            height: scrollView.bounds.size.height
        )
        scrollView.contentOffset = CGPoint(x: scrollView.bounds.width * 2, y: 0)
        initialTilingChildViewController(with: page)
    }
    
    private func placeNewViewControllerOnRight(with rightEdge: CGFloat, index: Int, dataSource: PagingContentViewControllerDataSource) -> Content? {
        let nextIndex = (index + 1) % numberOfPages
        guard (0..<numberOfPages) ~= nextIndex else { return nil }
        
        let vc = dataSource.contentViewController(viewController: self, viewControllerAt: nextIndex)
        let content = (index: nextIndex, vc: vc)
        
        addChildViewController(vc)
        scrollView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)

        visibleViewControllers.append(content)
        
        vc.view.frame.size = scrollView.bounds.size
        vc.view.frame.origin =  CGPoint(x: rightEdge, y: 0)
        return content
    }
    
    private func placeNewViewControllerOnLeft(with leftEdge: CGFloat, index: Int, dataSource: PagingContentViewControllerDataSource) -> Content? {
        let nextIndex: Int
        if index == 0 {
            nextIndex = numberOfPages - 1
        } else {
            nextIndex = (index - 1) % numberOfPages
        }
        guard (0..<numberOfPages) ~= nextIndex else { return nil }
        
        let vc = dataSource.contentViewController(viewController: self, viewControllerAt: nextIndex)
        let content = (index: nextIndex, vc: vc)
        
        addChildViewController(vc)
        scrollView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        
        visibleViewControllers.insert(content, at: 0)
        
        vc.view.frame.size = scrollView.bounds.size
        vc.view.frame.origin =  CGPoint(x: leftEdge - scrollView.bounds.size.width, y: 0)
        return content
    }
    
    private func placeNewViewControllerOnCenter(index: Int, dataSource: PagingContentViewControllerDataSource) -> Content? {
        guard (0..<numberOfPages) ~= index else { fatalError() }
        
        let vc = dataSource.contentViewController(viewController: self, viewControllerAt: index)
        let content = (index: index, vc: vc)
        
        addChildViewController(vc)
        scrollView.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
        
        vc.view.frame.size = scrollView.bounds.size
        vc.view.center = CGPoint(x: scrollView.contentSize.width/2, y: scrollView.contentSize.height/2)
        return content
    }
    
    private func initialTilingChildViewController(with index: Int) {
        guard let dataSource = dataSource, 0 < numberOfPages, visibleViewControllers.isEmpty else {
            return
        }
        
        guard let content = placeNewViewControllerOnCenter(index: index, dataSource: dataSource) else {
            return
        }
        
        visibleViewControllers = [content]
    }
    
    private func tileChildViewControllers(from minX: CGFloat, to maxX: CGFloat) {
        guard let dataSource = dataSource, 0 < numberOfPages, !visibleViewControllers.isEmpty else {
            return
        }
        
        var lastContent = visibleViewControllers.last
        var rightEdge = lastContent?.vc.view.frame.maxX
        while let _lastContent = lastContent, let _rightEdge = rightEdge, _rightEdge < maxX {
            lastContent = placeNewViewControllerOnRight(with: _rightEdge, index: _lastContent.index, dataSource: dataSource)
            rightEdge = lastContent?.vc.view.frame.maxX
        }

        var firstContent = visibleViewControllers.first
        var leftEdge = firstContent?.vc.view.frame.minX
        while let _firstContent = firstContent, let _leftEdge = leftEdge, _leftEdge > minX {
            firstContent = placeNewViewControllerOnLeft(with: _leftEdge, index: _firstContent.index, dataSource: dataSource)
            leftEdge = firstContent?.vc.view.frame.minX
        }
        
        while let lastContent = visibleViewControllers.last.flatMap({$0}), lastContent.vc.view.frame.minX > maxX {
            lastContent.vc.view.removeFromSuperview()
            lastContent.vc.removeFromParentViewController()
            visibleViewControllers.removeLast()

        }
        
        while let firstContent = visibleViewControllers.first.flatMap({$0}), firstContent.vc.view.frame.maxX < minX {
            firstContent.vc.view.removeFromSuperview()
            firstContent.vc.removeFromParentViewController()
            visibleViewControllers.removeFirst()
        }
    }
}

extension PagingContentViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.layer.removeAllAnimations()
        isExplicityScrolling = true
        let leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        delegate?.contentViewController(viewController: self, willBeginManualScrollOn: leftSidePageIndex)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isExplicityScrolling {
            let leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            let leftSideContentOffset = CGFloat(leftSidePageIndex) * scrollView.bounds.width
            let percent = (scrollView.contentOffset.x - leftSideContentOffset) / scrollView.bounds.width
            let normalizedPercent = min(max(0, percent), 1)
            let content = visibleViewControllers.filter { $0.vc.view.frame.contains(scrollView.contentOffset) }.first!
            print(content.index)
            delegate?.contentViewController(viewController: self, didManualScrollOn: content.index, percent: normalizedPercent)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        let leftPage = floor(scrollView.contentOffset.x / scrollView.bounds.width)
        let page = (0 < velocity.x) ? leftPage : leftPage + 1
        let offsetX = scrollView.bounds.width * page

        let content = visibleViewControllers.filter { $0.vc.view.frame.contains(scrollView.contentOffset) }.first!
        let absolutePage = (0 < velocity.x) ? content.index : content.index + 1
        print(absolutePage)
        delegate?.contentViewController(viewController: self, willEndManualScrollOn: Int(absolutePage))
        performSystemAnimation({ [weak self] in
            self?.scrollView.contentOffset.x = offsetX
        })
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isExplicityScrolling {
            let leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            delegate?.contentViewController(viewController: self, didEndManualScrollOn: leftSidePageIndex)
        }
        isExplicityScrolling = false
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        if isExplicityScrolling {
            let leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            delegate?.contentViewController(viewController: self, didEndManualScrollOn: leftSidePageIndex)
        }
        isExplicityScrolling = false
    }
}

private func performSystemAnimation(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    UIView.perform(
        .delete,
        on: [],
        options: .allowUserInteraction,
        animations: animations,
        completion: completion
    )
}
