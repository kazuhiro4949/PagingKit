//
//  IndicatorViewController.swift
//  iOS Sample
//
//  Created by kahayash on 2017/10/28.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class IndicatorViewController: UIViewController {
    var contentViewController: PagingContentViewController!
    var menuViewController: PagingMenuViewController!
    
    var dataSource: [UIViewController] = [
        {
            let vc = UIStoryboard(name: "PhotoViewController", bundle: nil).instantiateInitialViewController() as! PhotoViewController
            vc.image = #imageLiteral(resourceName: "Photo1")
            return vc
        }(),
        {
            let vc = UIStoryboard(name: "PhotoViewController", bundle: nil).instantiateInitialViewController() as! PhotoViewController
            vc.image = #imageLiteral(resourceName: "Photo2")
            return vc
        }()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuViewController?.registerFocusView(nib: UINib(nibName: "IndicatorFocusMenuView", bundle: nil))
        menuViewController?.register(type: PagingMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        
        menuViewController?.reloadData()
        contentViewController?.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.delegate = self
            contentViewController.dataSource = self
        } else if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.delegate = self
            menuViewController.dataSource = self
        }
    }

}


extension IndicatorViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return viewController.view.bounds.width / CGFloat(dataSource.count)
    }

    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

extension IndicatorViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index]
    }
}

extension IndicatorViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController?.scroll(to: page, animated: true)
    }
}

extension IndicatorViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}

