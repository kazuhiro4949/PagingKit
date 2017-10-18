![img](https://user-images.githubusercontent.com/18320004/31583441-eb6ff894-b1d6-11e7-943a-675d6460919a.png)


[![Platform](https://img.shields.io/cocoapods/p/PagingKit.svg?style=flat)](http://cocoapods.org/pods/PagingKit)
![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg)
![Swift 3.2](https://img.shields.io/badge/Swift-3.2-orange.svg)
[![License](https://img.shields.io/cocoapods/l/PagingKit.svg?style=flat)](http://cocoapods.org/pods/PagingKit)
[![Version](https://img.shields.io/cocoapods/v/PagingKit.svg?style=flat)](http://cocoapods.org/pods/PagingKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

PagingKit provides customizable menu & content UI. It has more flexible layout and design than the other libraries.

# What's this?
There are many libraries providing "Paging UI" which have menu and content area.
They are convinience but not customizable because your app have to make compatible with the libraries about layout and view components.
When your philosophy doesn't fit the libraries, you need to fork them or find another one. 

PagingKit has more flexible layout and design than the other libraries.
You can construct "Menu" and "Content" UI, and they work together. That's all features this library provides.
You can fit layout and design of Pagingin UI to your apps as you like.

![paging_sample](https://user-images.githubusercontent.com/18320004/31575892-35860ae2-b12b-11e7-9525-1825c69b094f.gif)

## Customized layout 

| changing position of Menu and Content | placing a view between Menu and Content |
|:------------:|:------------:|
| ![paging_sample3](https://user-images.githubusercontent.com/18320004/27946963-fc4d0ee6-632e-11e7-9bcb-1cf171ffdc88.gif) | ![paging_sample2](https://user-images.githubusercontent.com/18320004/27946966-fe94c216-632e-11e7-96db-d8e0ec9acecb.gif) |


## Customized menu design

| tag like menu design | text highlighted menu design | underscore design|
|:------------:|:------------:|:------------:|
| ![tag](https://user-images.githubusercontent.com/18320004/28256285-bbf663b8-6afb-11e7-9779-7d9716dbb87a.gif) | ![overlay](https://user-images.githubusercontent.com/18320004/28256286-bd274f40-6afb-11e7-8662-7fea65b608f3.gif) | ![paging_sample](https://user-images.githubusercontent.com/18320004/27948466-d94665b8-6334-11e7-8bd8-a5d28eddb797.gif) |



# Feature
- [x] easy to construct Paging UI
- [x] customizable layout and design
- [x] UIKit like API

# Requirements
+ iOS 8.0+
+ Xcode 9.0+
+ Swift 4.0 (3.2)

# Installation

### CocoaPods
+ Install CocoaPods
```
> gem install cocoapods
> pod setup
```
+ Create Podfile
```
> pod init
```
+ Edit Podfile
```ruby
target 'YourProject' do
  use_frameworks!

  pod "PagingKit" # add

  target 'YourProject' do
    inherit! :search_paths
  end

  target 'YourProject' do
    inherit! :search_paths
  end

end
```

+ Install

```
> pod install
```
open .xcworkspace

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
import PagingKit
```

# Usage

There are some samples in this library.

https://github.com/kazuhiro4949/PagingKit/tree/master/iOS%20Sample/iOS%20Sample

You can fit PagingKit into your project as the samples do. Check out this repository and open the workspace.

PagingKit has two essential classes.
- PagingMenuViewController
- PagingContentViewController

PagingMenuViewController provides interactive menu for each content. PagingContentViewController provides the contents on a scrollview.

If you will make a new UI which contains PagingKit, refer the following 4 steps.

- 1. Add PagingMenuViewController & PagingContentViewController
- 2. Assign them to properties
- 3. Create menu UI
- 4. display data
- 5. Synchronize Menu and Content view controllers

# 1. Add PagingMenuViewController & PagingContentViewController
First, add PagingMenuViewController & PagingContentViewController on container view with Stroyboard.

## 1. Put container view on Storyboard
Put container view on stroyboard for each the view controllers.

<img width="1417" alt="2017-08-25 16 33 51" src="https://user-images.githubusercontent.com/18320004/29704102-491f0e72-89b3-11e7-9d69-7988969ef18e.png">

## 2. Change class names

Set PagingMenuViewController to custom class setting.
<img width="1418" alt="2017-08-25 16 36 36" src="https://user-images.githubusercontent.com/18320004/29704183-a59ab390-89b3-11e7-9e72-e98ee1e9abc0.png">

Set PagingContentViewController to custom class setting.

<img width="1415" alt="2017-08-25 16 36 54" src="https://user-images.githubusercontent.com/18320004/29704184-a669f344-89b3-11e7-91b6-90669fa2190f.png">

# 2. Assign them to properties

Assign them to the container view controller on code.

## 1. Declare properties for the view controllers 
Declare properties in container view controller.
```swift
class ViewController: UIViewController {
    
    var menuViewController: PagingMenuViewController!
    var contentViewController: PagingContentViewController!
```

## 2. override prepare(segue:sender:) and assign the view controllers
Assigin view controllers to each the property in prepare(segue:sender:) method.

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
Change menu color.
<img width="1097" alt="2017-08-25 17 47 58" src="https://user-images.githubusercontent.com/18320004/29706662-922732ac-89bd-11e7-8969-bd6fbe394a8a.png">

Build and check current result.

<img width="487" alt="2017-08-25 17 47 29" src="https://user-images.githubusercontent.com/18320004/29706651-84749258-89bd-11e7-9239-6919a0175a17.png">

It is the container view controller that has two conten view controllers.

# 3. Create menu UI

Next, you needs to prepare menu element.

## 1. Inherite PagingMenuViewCell and create custom cell

PagingKit has PagingMenuViewCell. PagingMenuViewController uses it to construct menu element.

```swift
import UIKit
import PagingKit

class MenuCell: PagingMenuViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```

<img width="1414" alt="2017-08-25 16 56 56" src="https://user-images.githubusercontent.com/18320004/29704850-7b877cd4-89b6-11e7-98c9-48eb94646291.png">


## 2. Inherite PagingFocusView and create custom view

PagingKit has PagingFocusView. PagingMenuViewController uses it to show current focusted menu.

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

# 4. display data

Then, implement the data sources to display contents. They are a similar interfaces to UITableViewDataSource.

## 1. prepare data

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

Return number of menus, menu widthes and menu assigned cells.

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
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
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

Return number of contents and content assigned cells.


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
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return dataSource[index].vc
    }
}
```

## 4. load UI

Call UITableView.reloadData() methods with starting point.

```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        //...
        //...
        menuViewController.reloadData(startingOn: 0)
        contentViewController.reloadData(with: 0)
    }
```

Build and display data source.

<img width="487" alt="2017-08-25 17 54 30" src="https://user-images.githubusercontent.com/18320004/29706950-7e1b41a8-89be-11e7-8bb2-fc90afbe11f7.png">

# 5. Synchronize Menu and Content view controllers

Last, synchronize user interactions on Menu and Content.

## 1. set menu delegate

Implement menu delegate to handle the event. It is a similar interfaces to UITableViewDelegate. You need to scroll method of content view controller on the delegate method.

```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self // <- set menu delegate
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self
        }
    }
}
```

```swift

extension ViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController.scroll(to: page, animated: true)
    }
}
```

## 2. set content delegate

Implement content delegate to handle the event. It is a similar interfaces to UIScrollViewDelegate. You need to scroll method of content view controller on the delegate method. Percent parameter is based on the left to right distance.

```swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController.dataSource = self
            menuViewController.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController.dataSource = self
            contentViewController.delegate = self // <- set content delegate
        }
    }
}
```

```swift
extension ViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController.scroll(index: index, percent: percent, animated: false)
    }
}
```

That's it.

# Class Design
There are some design policy in this library.

- The behavior needs to be specified by the library.
- The layout should be left to developers.
- Arrangement of the internal components must be left to developers.
- Favour composition over inheritance.

Because of that, PagingKit has responsiblity for the behavior. But it doesn't specify a structure of the components.
PagingKit favours composition over inheritance. This figure describes overview of class diagram.


![project](https://user-images.githubusercontent.com/18320004/31725275-e77fa07e-b45e-11e7-83de-0ce621159526.png)

# License

Copyright (c) 2017 Kazuhiro Hayashi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
