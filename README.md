# SelectionDropDownView
SelectionDropDownView is a dropdown view for iOS. It allows you to select multiple amount of items.


![alt tag](https://github.com/madoffox/SelectionDropDownView/blob/master/ScreenRecording_04-22-2018%2022:26.gif)

## Usage

Setting up is easy. First, you need to initialize a SelectionDropDownView in your view
```swift
let frame = CGRect(x: 10, y: 40, width: self.view.frame.width-20, height: self.view.frame.height/3 )
let selectionDropDownView = SelectionDropDownView(frame: frame)
```

After your SelectionDropDownView is initialized, you should specify which items to be displayed inside the SelectionDropDownView

```swift
selectionDropDownView.listOfItems = ["abc", "abcd", "abcde","abcdef","abcdefg"]
```

When you are ready, conform your class to the `SelectionDropDownViewDelegate` and implement the `selectionView` method.

```swift
selectionDropDownView.delegate = self

extension ViewController: SelectionDropDownViewDelegate {
    func selectionView(_ selectionView: SelectionDropDownView, didAppendItem item: String, toList list: [String]) {
        print("item:","\n", item)
        print("---------------")
        print("list:","\n",list)
    }  
}
```

## Properties

#### Change color
Changes colors that are used in selectionDropDownView
- `selectionDropDownView.mainColor = .blue`

#### Deleting items
If it is set to false, items will not return to list after deleting
- `selectionDropDownView.shouldReturnDeletedItemsToList = true`

#### Corner radius
Sets corner radius to subviews inside selectionDropDownView
- `selectionDropDownView.cornerRadius = 12`
