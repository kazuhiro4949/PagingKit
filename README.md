# PagingKit
PagingKit provides customisable menu & content UI.

![Swift 3.0+](https://img.shields.io/badge/Swift-3.0+-orange.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

![paging_sample](https://user-images.githubusercontent.com/18320004/27948466-d94665b8-6334-11e7-8bd8-a5d28eddb797.gif)


# What's this?
There are many libaries providing "Paging UI" which has menu and content area.
They are convinience but not customizable because your app have to make compatible with the library about layout and design.
When It doesn't fit the libaries, you need to fork the library or find another one. 

PagingKit has more flexible layout and design than the other libraries.
You can construct "Menu" and "Content" UI, and they work together. That's all features this library provides.
You can fit layout and design of Pagingin UI to your apps as you like.

## Customized layout 

| changing position of Menu and Content | placing a view between Menu and Content |
|:------------:|:------------:|
| ![paging_sample3](https://user-images.githubusercontent.com/18320004/27946963-fc4d0ee6-632e-11e7-9bcb-1cf171ffdc88.gif) | ![paging_sample2](https://user-images.githubusercontent.com/18320004/27946966-fe94c216-632e-11e7-96db-d8e0ec9acecb.gif) |


## Customized menu desing

| tag like menu desing | text highlighted menu design |
|:------------:|:------------:|
| ![tag](https://user-images.githubusercontent.com/18320004/28256285-bbf663b8-6afb-11e7-9779-7d9716dbb87a.gif) | ![overlay](https://user-images.githubusercontent.com/18320004/28256286-bd274f40-6afb-11e7-8662-7fea65b608f3.gif) |



# Feature
- [x] easy to costruct Paging UI many media Apps have
- [x] customizable layout and design
- [x] UIKit like API

# Requirements
+ iOS 8.0+
+ Xcode 8.1+
+ Swift 3.0+

# Installation
## Carthage
+ Install Carthage from Homebrew
```
> ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
> brew update
> brew install carthage
```
+ Move your project dir and create Cartfile
```
> touch Cartfile
```
+ add the following line to Cartfile
```
github "kazuhiro4949/PagingKit"
```
+ Create framework
```
> carthage update --platform iOS
```

+ In Xcode, move to "Genera > Build Phase > Linked Frameworks and Library"
+ Add the framework to your project
+ Add a new run script and put the following code
```
/usr/local/bin/carthage copy-frameworks
```
+ Click "+" at Input file and Add the framework path
```
$(SRCROOT)/Carthage/Build/iOS/PagingKit.framework
```
+ Write Import statement on your source file
```
Import PagingKit
```

# Usage

There are some sample projects in this library.

https://github.com/kazuhiro4949/PagingKit/tree/master/iOS%20Sample/iOS%20Sample

You can put PagingKit into your project as the sample codes do.

PagingKit has two essential classes.
- PagingMenuViewController
- PagingContentViewController

PagingMenuViewController provides interactive menu for each content. 
PagingContentViewController provides the contents on paging view.

If you wanna make a new view controller that contains PagingKit, refer the following steps.

# 1. Add PagingMenuViewController & PagingContentViewController

## 1. Put container view on Storyboard

<img width="1417" alt="2017-08-25 16 33 51" src="https://user-images.githubusercontent.com/18320004/29704102-491f0e72-89b3-11e7-9d69-7988969ef18e.png">

## 2. Change class names

<img width="1418" alt="2017-08-25 16 36 36" src="https://user-images.githubusercontent.com/18320004/29704183-a59ab390-89b3-11e7-9e72-e98ee1e9abc0.png">
<img width="1415" alt="2017-08-25 16 36 54" src="https://user-images.githubusercontent.com/18320004/29704184-a669f344-89b3-11e7-91b6-90669fa2190f.png">

# 2. Assign them to properties

## 1. Declare properties for the view controllers 
```swift
class ViewController: UIViewController {
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
```

## 2. override prepare(segue:sender:) and assign the view controllers
```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
        }
    }
```

## 3. Build App
<img width="1097" alt="2017-08-25 17 47 58" src="https://user-images.githubusercontent.com/18320004/29706662-922732ac-89bd-11e7-8969-bd6fbe394a8a.png">

<img width="487" alt="2017-08-25 17 47 29" src="https://user-images.githubusercontent.com/18320004/29706651-84749258-89bd-11e7-9239-6919a0175a17.png">


# 3. Create menu UI

## 1. Inherite PagingMenuViewCell and create custom cell
```swift
import UIKit
import PagingKit

class MenuCell: PagingMenuViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```

<img width="1414" alt="2017-08-25 16 56 56" src="https://user-images.githubusercontent.com/18320004/29704850-7b877cd4-89b6-11e7-98c9-48eb94646291.png">


## 2. Inherite PagingFocusView and create custom view

<img width="1420" alt="2017-08-25 16 59 07" src="https://user-images.githubusercontent.com/18320004/29704919-bd3d8f06-89b6-11e7-88dc-c8546979dbde.png">


## 3. register the above views to PagingMenuViewController

```swift
class ViewController: UIViewController {
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController.register(nib: UINib(nibName: "MenuCell", bundle: nil), forCellWithReuseIdentifier: "MenuCell")
        menuViewController.registerFocusView(nib: UINib(nibName: "FocusView", bundle: nil))
    }
```

# 3. display data
## 1. prepare data sources

```swift
class ViewController: UIViewController {
    static var viewController: (UIColor) -> UIViewController = { (color) in
       let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    var dataSource = [(menuTitle: "test1", vc: viewController(.red)), (menuTitle: "test2", vc: viewController(.blue)), (menuTitle: "test3", vc: viewController(.yellow))]
```

## 2. set menu data source
```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self // <- set menu data source
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
        }
    }
}

extension ViewController: PagingMenuViewControllerDataSource {
    func numberOfItemForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return 100
    }
    
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: index) as! MenuCell
        cell.titleLabel.text = dataSource[index].menuTitle
        return cell
    }
}
```

## 3. configure content data source
```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self // <- set content data source
        }
    }
}

extension ViewController: PagingContentViewControllerDataSource {
    func numberOfItemForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].vc
    }
}
```

## 4. load UI
```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        //...
        //...
        menuViewController.reloadData(startingOn: 0)
        contentViewController.reloadData(with: 0)
    }
```

<img width="487" alt="2017-08-25 17 54 30" src="https://user-images.githubusercontent.com/18320004/29706950-7e1b41a8-89be-11e7-8bb2-fc90afbe11f7.png">


# Class Design
# License

Copyright (c) 2017 Kazuhiro Hayashi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
