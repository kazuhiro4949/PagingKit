//
//  FullscreenViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2017/10/28.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class FullscreenViewController: UIViewController {
    var contentViewController: PagingContentViewController!
    var menuViewController: PagingMenuViewController!
    
    let dataSource: [(menu: (title: String, color: UIColor), content: UIViewController)] = ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"].map {
        let title = $0
        let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
        let color = UIColor(
            red: (CGFloat(arc4random_uniform(255)) + 1) / 255,
            green: (CGFloat(arc4random_uniform(255)) + 1) / 255,
            blue: (CGFloat(arc4random_uniform(255)) + 1) / 255,
            alpha: 1
        )
        return (menu: (title: title, color: color), content: vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController?.register(nib: UINib(nibName: "TagMenuCell", bundle: nil), forCellWithReuseIdentifier: "identifier")
        menuViewController?.reloadData(with: 4)
        contentViewController?.reloadData(with: 4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        } else if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController?.dataSource = self
            menuViewController?.delegate = self
        }
    }

    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension FullscreenViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension FullscreenViewController: PagingMenuViewControllerDataSource {
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        TagMenuCell.sizingCell.titieLabel.text = dataSource[index].menu.title
        var referenceSize = UIView.layoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = TagMenuCell.sizingCell.systemLayoutSizeFitting(referenceSize)
        return size.width
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TagMenuCell
        cell.titieLabel.text = dataSource[index].menu.title
        cell.contentView.backgroundColor = dataSource[index].menu.color
        let percent: CGFloat = viewController.currentFocusedIndex == index ? 1 : 0
        cell.focus(percent: percent)
        return cell
    }
}


extension FullscreenViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        viewController.visibleCells.compactMap { $0 as? TagMenuCell }.forEach { $0.focus(percent: 0, animated: true) }
        let nextCell = viewController.cellForItem(at: page) as? TagMenuCell
        nextCell?.focus(percent: 1, animated: true)
        
        
        contentViewController?.scroll(to: page, animated: true)
    }
}

extension FullscreenViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        let leftCell = menuViewController.cellForItem(at: index) as? TagMenuCell
        let rightCell = menuViewController.cellForItem(at: index + 1) as? TagMenuCell
        
        leftCell?.focus(percent: (1 - percent))
        rightCell?.focus(percent: percent)
        
        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}
