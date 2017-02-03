# FlippingLabel
UILabel acting like a "flipping clock"  tile


![alt tag](https://github.com/Melomat/FlippingLabel/blob/master/FlippingLabel.gif)

Requirements

FlippingLabel requires Xcode 8, targeting iOS 9.0

Usage
------

To use this Label, just import FlippingLabel.swift to your project.
Once imported, add a UILabel into your storyboard/xib file, and change it's class to FlippingLabel.

To change the label text using a fliping animation, just call the updateWithText() method on your FlippingLabel like so :
```Swift
myLabel.updateWithText("My awesome text")
```
It will automatically animate your label text with a nice flipping animation

Feedback
------

  * If you found a **bug**, open an **issue**
  * If you have a **feature request**, open an **issue**
  * If you want to **contribute**, submit a **pull request**

Contact
------

* [@melomat](https://github.com/melomat/) on github

License
------

FlippingLabel is under the MIT license. See the LICENSE file for more information.
