//
//  PagingContentViewController.swift
//  PagingViewController
//
//  Created by Kazuhiro Hayashi on 7/2/17.
//  Copyright © 2017 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public protocol PagingContentViewControllerDelegate: class {
    
    func contentViewController(viewController: PagingContentViewController, willBeginScrollFrom index: Int)
    func contentViewController(viewController: PagingContentViewController, didScrollOn index: Int, percent: CGFloat)
    func contentViewController(viewController: PagingContentViewController, didEndScrollFrom previousIndex: Int, to nextIndex: Int, transitionComplete: Bool)
}

extension PagingContentViewControllerDelegate {
    
    public func contentViewController(viewController: PagingContentViewController, willBeginScrollFrom index: Int){}
    public func contentViewController(viewController: PagingContentViewController, didScrollOn index: Int, percent: CGFloat) {}
    public func contentViewController(viewController: PagingContentViewController, didEndScrollFrom previousIndex: Int, to nextIndex: Int, transitionComplete: Bool) {}
}

public protocol PagingContentViewControllerDataSource: class {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int
    func contentViewController(viewController: PagingContentViewController, viewControllerAt Index: Int) -> UIViewController
}

public class PagingContentViewController: UIViewController {
    private var cachedViewControllers = [UIViewController?]()
    
    public weak var delegate: PagingContentViewControllerDelegate?
    public weak var dataSource: PagingContentViewControllerDataSource?
    
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
        initialLoad(with: page)
        scroll(to: page, animated: false)
    }
    
    public func scroll(to page: Int, animated: Bool) {
        isProgramaticallyScrolling = true
        let offsetX = scrollView.bounds.width * CGFloat(page)
        let offset = CGPoint(x: offsetX, y: 0)
        loadPagesIfNeeded(page: page)
        scrollView.setContentOffset(offset, animated: animated)
        if !animated {
            isProgramaticallyScrolling = false
        }
    }
    
    fileprivate var numberOfPages: Int = 0
    
    fileprivate var lastContentOffset = CGPoint.zero
    fileprivate var leftSidePageIndex = 0
    fileprivate(set) var isProgramaticallyScrolling = false
    
    fileprivate let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        return scrollView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if cachedViewControllers.isEmpty {
            initialLoad(with: 0)
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.bounds.size.width * CGFloat(numberOfPages), height: view.bounds.size.height)
        cachedViewControllers.enumerated().forEach { (offset, vc) in
            vc?.view.frame = scrollView.bounds
            vc?.view.frame.origin.x = scrollView.bounds.width * CGFloat(offset)
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let _currentPageIndex = currentPageIndex
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            guard let _self = self else { return }
            _self.initialLoad(with: _currentPageIndex)
            
            let point = CGPoint(x: _self.scrollView.bounds.width * CGFloat(_currentPageIndex), y: 0)
            _self.scrollView.setContentOffset(point, animated: false)
        }) { (context) in }
    }
    
    fileprivate func initialLoad(with page: Int) {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        childViewControllers.forEach { $0.removeFromParentViewController() }
        
        numberOfPages = dataSource?.numberOfItemForContentViewController(viewController: self) ?? 0
        cachedViewControllers = Array(repeating: nil, count: numberOfPages)
        
        loadScrollView(with: page - 1)
        loadScrollView(with: page)
        loadScrollView(with: page + 1)
    }
    
    fileprivate func loadScrollView(with page: Int) {
        guard (0..<cachedViewControllers.count) ~= page else { return }
        
        if case nil = cachedViewControllers[page], let dataSource = dataSource {
            let vc = dataSource.contentViewController(viewController: self, viewControllerAt: page)
            addChildViewController(vc)
            vc.view.frame = scrollView.bounds
            vc.view.frame.origin.x = scrollView.bounds.width * CGFloat(page)
            scrollView.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            cachedViewControllers[page] = vc
        }
    }
}

extension PagingContentViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard !isProgramaticallyScrolling else { return }
        
        delegate?.contentViewController(viewController: self, willBeginScrollFrom: leftSidePageIndex)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isProgramaticallyScrolling else { return }
        
        let leftSideContentOffset = CGFloat(leftSidePageIndex) * scrollView.bounds.width
        let percent = (scrollView.contentOffset.x - leftSideContentOffset) / scrollView.bounds.width
        
        delegate?.contentViewController(viewController: self, didScrollOn: leftSidePageIndex, percent: min(max(0, percent), 1))
        
        lastContentOffset = scrollView.contentOffset
        leftSidePageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadPagesIfNeeded()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadPagesIfNeeded()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isProgramaticallyScrolling = false
    }
    
    fileprivate func loadPagesIfNeeded(page: Int? = nil) {
        let loadingPage = page ?? currentPageIndex
        loadScrollView(with: loadingPage - 1)
        loadScrollView(with: loadingPage)
        loadScrollView(with: loadingPage + 1)
    }
}
