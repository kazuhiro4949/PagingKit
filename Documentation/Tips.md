# Tips
## Build-in UI components
```TitleLabelMenuViewCell``` and ```UnderlineFocusView``` are build-in UI components. You don't need to make custom PagingMenuViewCell and PagingFoucsView, when your App require simple UI. 

[SimpleViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/SimpleViewController.swift) in this repository helps you to understand usege. 

## Creating your custom UI components
PagingKit expects you to create a menu cell and foucs view. You can create and register them like UITableViewCell.

Read [this section](https://github.com/kazuhiro4949/PagingKit#3-create-menu-ui) or some sample code.

- [TagMenuCell](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/TagMenuCell.swift)
- [OverlayMenuCell](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/OverlayMenuCell.swift) and [OverlayFocusView](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/OverlayFocusView.swift)

## Focused Cell Style
```PagingMenuViewCell``` has ```isSelected``` property. ```PagingMenuView``` updates the property if the focusing cell is changed. You can change the style　ｂｙ overriding the property.

```swift
class CustomCell: PagingMenuViewCell {
    override public var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = focusColor
            } else {
                titleLabel.textColor = normalColor
            }
        }
    }
}
```

## Cell Alignment
```PagingMenuViewController``` has an utility method to align cellls. 

https://github.com/kazuhiro4949/PagingKit/blob/master/PagingKit/PagingMenuViewController.swift#L110

If you want to align cells on the center, the following code will help you.

```swift
pagingMenuViewController.cellAligenment = .center
```

## Underline to have the same width as each title label

There is no feature to adjust the underline width in PagingKit.
But you can adjust by yourself on your view controller. 

How to make the UI:

First, you need to make a subclasses of PagingFocusView as follows.
The view for underline has a constant width constraint (required priority) and the same width constraint as the parent view width (high priority).

<img width="487" alt="2018-06-15 22 23 20" src="https://user-images.githubusercontent.com/18320004/41470284-1bd98cc4-70eb-11e8-9263-0fc32d5226fe.png">

Connect IBOutliet with the constant width constraint.

```swift
class FocusView: UIView {
    @IBOutlet weak var underlineWidthConstraint: NSLayoutConstraint!
}
```

The class inherited to PagingMenuViewCell has the center constraints and.

<img width="487" alt="2018-06-15 22 21 35" src="https://user-images.githubusercontent.com/18320004/41470293-22cfad06-70eb-11e8-8a7a-52ad8774e3ca.png">

Then, binds the subclass of PagingFocusView as property on your view controller.

```swift
var focusView: FocusView! // <- binds focusview
override func viewDidLoad() {     
    focusView = UINib(nibName: "FocusView", bundle: nil).instantiate(withOwner: self, options: nil).first as! FocusView
    menuViewController?.registerFocusView(view: focusView)
```

Finally, set the underline width on each the paging event.

```swift
    /// adjust focusView width
    ///
    /// - Parameters:
    ///   - index: current focused left index
    ///   - percent: percent of left to right
    func adjustfocusViewWidth(index: Int, percent: CGFloat) {
        guard let leftCell = menuViewController?.cellForItem(at: index) as? LabelCell else {
            return // needs to have left cell
        }
        guard let rightCell = menuViewController?.cellForItem(at: index + 1) as? LabelCell else {
            focusView.underlineWidthConstraint.constant = leftCell.titleLabel.bounds.width
            return // If the argument to cellForItem(at:) is last index, rightCell is nil
        }
        // calculate the difference
        let diff = (rightCell.titleLabel.bounds.width - leftCell.titleLabel.bounds.width) * percent
        focusView.underlineWidthConstraint.constant = leftCell.titleLabel.bounds.width + diff
    }
```

```swift
extension SimpleViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController?.scroll(index: index, percent: percent, animated: false)
        adjustfocusViewWidth(index: index, percent: percent) // <- adjusts underline view width
    }
}
```

<img width="200" alt="2018-06-15 22 21 35" src="https://user-images.githubusercontent.com/18320004/41470870-e369f890-70ec-11e8-8065-f8b26352ef77.gif">

## Controlling PagingContentViewController's scroll

PagingContentViewController uses UIScrollView to scroll the contents.

You can disable the pan gesture as follows.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // contentViewController is a PagingContentViewController's object.
    // ...
    pagingContentView.scrollView.isScrollEnabled = false
}
```

Set false to “delaysContentTouches” in the scroll view when you have some controls (e.g. UISlider) in your contents.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // contentViewController is a PagingContentViewController's object.
    // ...
    contentViewController.scrollView.delaysContentTouches = false
}
```

## Initializing without Storyboard
Each class in PagingKit is kind of UIViewController or UIView.

So you can initialize them as you initialize UIViewController or UIView.

Sample Project has this case. see [InitializeWithoutStoryboardViewController](https://github.com/kazuhiro4949/PagingKit/blob/master/iOS%20Sample/iOS%20Sample/InitializingWithoutStoryboardViewController.swift)

## Code Snippets
There are some snippets to save your time. 

- https://github.com/kazuhiro4949/PagingKit/tree/master/tools/CodeSnippets

Install them on ```~/Library/Developer/Xcode/UserData/CodeSnippets/``` and restart Xcode. You can see the snippets on the right pane.

![1 -04-2018 16-33-59](https://user-images.githubusercontent.com/18320004/34553858-1e8a4876-f16d-11e7-97e1-605fa68896fd.gif)

