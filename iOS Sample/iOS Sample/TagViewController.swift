//
//  TagViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2017/07/15.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class TagViewController: UIViewController {
    var contentViewController: PagingContentViewController!
    var menuViewController: PagingMenuViewController!
    
    let dataSource: [(menu: (title: String, color: UIColor), content: UIViewController)] = ["Martinez", "Alfred", "Louis", "Justin", "Tim", "Deborah", "Michael", "Choi", "Hamilton", "Decker", "Johnson", "George"].map {
        let title = $0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        vc.number = title
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
        menuViewController?.reloadDate(startingOn: 0) { [weak self] _ in
            let cell = self?.menuViewController.currentFocusedCell as! TagMenuCell
            cell.focus(percent: 1)
        }
        contentViewController?.reloadData(with: 0)
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
}

extension TagViewController: PagingContentViewControllerDataSource {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].content
    }
}

extension TagViewController: PagingMenuViewControllerDataSource {
    func numberOfItemForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, areaForItemAt index: Int) -> CGFloat {
        TagMenuCell.sizingCell.titieLabel.text = dataSource[index].menu.title
        var referenceSize = UILayoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = TagMenuCell.sizingCell.systemLayoutSizeFitting(referenceSize)
        return size.width
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TagMenuCell
        cell.titieLabel.text = dataSource[index].menu.title
        cell.contentView.backgroundColor = dataSource[index].menu.color
        let percent: CGFloat = viewController.currentFocusedIndex == index ? 1 : 0
        cell.focus(percent: percent)
        return cell
    }
}


extension TagViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        let nextCell = viewController.cellForItem(at: page) as? TagMenuCell
        let prevCell = viewController.cellForItem(at: previousPage) as? TagMenuCell

        nextCell?.focus(percent: 1, animated: true)
        prevCell?.focus(percent: 0, animated: true)
        
        contentViewController?.scroll(to: page, animated: true)
    }
}

extension TagViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        let leftCell = menuViewController.cellForItem(at: index) as? TagMenuCell
        let rightCell = menuViewController.cellForItem(at: index + 1) as? TagMenuCell
        
        leftCell?.focus(percent: (1 - percent))
        rightCell?.focus(percent: percent)

        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}
