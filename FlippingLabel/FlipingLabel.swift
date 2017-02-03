//
//  FlipingLabel.swift
//  Boucing Test
//
//  Created by Matthias Mellouli on 14/05/2015.
//  Copyright (c) 2015 Matthias Mellouli. All rights reserved.
//

import UIKit

class FlipingLabel: UILabel {
    
    //Constants
    fileprivate let topAnimationDuration: CFTimeInterval! = 0.5
    fileprivate let bottomAnimationDuration: CFTimeInterval! = 0.1
    
    
    //Animation views
    fileprivate var newTextBottomView: UIView!
    fileprivate var previousTextTopView: UIView!
    fileprivate var previousTextBottomView: UIView!
    
    
//    //True if after the completion of the bottom tile animation we can remove
//    //the views safely
//    var canRemoveBottomView: Bool = false
    
    
    
    
    /// Updates the text of the label with a flip-flap animation
    /// snapshots Of the text to disapear are created, then the text is updated
    /// and snapshots of the text to appear are created. the snapshots are then
    /// added as subviews.
    /// - Parameter newText: the new text to be shown for the label
    func updateWithText(_ newText: String) {
        
        if text != newText {
            
            let (previousTextTopView, previousTextBottomView): (UIView, UIView) = createSnapshotViews()
            
            text = newText
            let (_, newTextBottomView): (UIView, UIView) = createSnapshotViews()
            
            
            self.newTextBottomView = newTextBottomView
            
            self.previousTextBottomView = previousTextBottomView
            self.previousTextTopView = previousTextTopView
            
            addSubview(previousTextTopView)
            addSubview(previousTextBottomView)
            
            //we clip the backbottomView to bounds for the shadow not to keep the
            // shadown that we will draw, inside the bounds of the view
            previousTextBottomView.clipsToBounds = true;
            
            
            clipsToBounds = false;
            
            animateTiles()
        }
    }
    
    
    
    
    /// Creates two snapshots of the displayed view. One for the top part and one
    /// for the bottom part
    ///
    /// - Returns: the top part snapshot and the bottom part snapshot
    fileprivate func createSnapshotViews()->(top:UIView, bottom:UIView) {
        
        // Render the view into an image:
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let renderedImage: UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        
        // The size of each part is half the height of the whole image:
        let snapshotSize: CGSize = CGSize(width: renderedImage.size.width, height: renderedImage.size.height / 2);
        
        var topSnapshotImage: UIImage
        var bottomSnapshotImage: UIImage
        
        
        UIGraphicsBeginImageContextWithOptions(snapshotSize, false, 0);
        
        // Draw into context, with bottom half cropped off
        renderedImage.draw(at: CGPoint.zero);
        
        // Grab the current contents of the context as a UIImage
        topSnapshotImage = UIGraphicsGetImageFromCurrentImageContext()!;
        
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContextWithOptions(snapshotSize, false, 0);
        
        // Now draw the image starting half way down, to get the bottom half
        renderedImage.draw(at: CGPoint(x: CGPoint.zero.x, y: -renderedImage.size.height / 2));
        // Grab the current contents of the context as a UIImage
        bottomSnapshotImage = UIGraphicsGetImageFromCurrentImageContext()!;
        
        UIGraphicsEndImageContext();
        
        
        let topView: UIImageView = UIImageView(image: topSnapshotImage)
        let bottomView: UIImageView = UIImageView(image: bottomSnapshotImage)
        topView.layer.allowsEdgeAntialiasing = true
        bottomView.layer.allowsEdgeAntialiasing = true
        bottomView.frame.origin.y = snapshotSize.height
        
        return (topView, bottomView);
        
    }
    
}



//MARK: - Animations
extension FlipingLabel {
    
    /// Start the flipping animation effect
    func animateTiles() {
        //Adding top tiles animations
        addTopTileSadowAnimation()
        addTopTileFlippingAnimation()
        
        addBottomShadowAnimation()
    }
    
    
    fileprivate func addTopTileSadowAnimation() {
        //The flipping top shadow is represented as subview with a black color
        //having its opcity changing
        let topViewShadow: UIView! = UIView(frame: previousTextTopView.bounds)
        topViewShadow.backgroundColor = UIColor.black
        topViewShadow.alpha = 0.0
        
        previousTextTopView.addSubview(topViewShadow)
        
        UIView.animate(withDuration: topAnimationDuration, animations: { () -> Void in
            topViewShadow.alpha = 0.3
        })
    }
    
    
    fileprivate func addTopTileFlippingAnimation() {
        let topAnimation = CABasicAnimation(keyPath: "transform.rotation.x")
        
        previousTextTopView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        previousTextTopView.center = CGPoint(x: previousTextTopView.frame.width/2.0, y: previousTextTopView.frame.height)
        
        topAnimation.duration = topAnimationDuration
        topAnimation.fromValue = 0.0
        topAnimation.toValue = M_PI_2
        topAnimation.delegate = self
        topAnimation.isRemovedOnCompletion = false;
        topAnimation.fillMode = kCAFillModeForwards
        topAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        topAnimation.setValue("topAnimation", forKey: "id")
        previousTextTopView.layer .add(topAnimation, forKey: "topRotation")
        
        var perspectiveTransform: CATransform3D = CATransform3DIdentity;
        perspectiveTransform.m34 = 1.0 / 400;
        perspectiveTransform = CATransform3DRotate(perspectiveTransform, CGFloat(M_PI_2), 1.0, 0.0, 0.0);
        previousTextTopView.layer.transform = perspectiveTransform;
    }
    
    
    /// Adds the bottom shadow animation to the previousTextBottomView (bottom
    /// tile that will be covered). It consists of a CAShaplayer withy black color
    /// and small opacity, having its shape changing depending
    fileprivate func addBottomShadowAnimation() {
        
        let bottomShadowLayer: CAShapeLayer = CAShapeLayer()
        let frame: CGRect! = CGRect(x: 0, y: 0, width: self.previousTextBottomView.frame.width*2, height: self.previousTextBottomView.frame.height*2)
        previousTextBottomView.layer.addSublayer(bottomShadowLayer)
        
        //we create the different shapes (3 total) for the shadow movment
        let path: UIBezierPath! = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        path.close()
        bottomShadowLayer.path = path.cgPath
        bottomShadowLayer.opacity = 0.2
        bottomShadowLayer.fillColor = UIColor.black.cgColor
        bottomShadowLayer.frame = frame
        
        let middlePath: UIBezierPath! = UIBezierPath()
        middlePath.move(to: CGPoint.zero)
        middlePath.addLine(to: CGPoint(x: frame.width, y: 0.0))
        middlePath.addLine(to: CGPoint(x: frame.width, y: 0.0))
        middlePath.addLine(to: CGPoint(x: frame.width, y: frame.height/3))
        middlePath.close()
        
        let endPath: UIBezierPath! = UIBezierPath()
        endPath.move(to: CGPoint.zero)
        endPath.addLine(to: CGPoint(x: frame.width, y: 0.0))
        endPath.addLine(to: CGPoint(x: frame.width, y: frame.height))
        endPath.addLine(to: CGPoint(x: 0.0, y: frame.height))
        endPath.close()
        
        
        //We create the keyframe animation for the shadow with the 3 paths just
        //Created corresponding to the keytimes 0, 0.6 and 1.0 (percents)
        let animation = CAKeyframeAnimation(keyPath: "path")
        animation.values = [path.cgPath, middlePath.cgPath, endPath.cgPath]
        animation.keyTimes = [0, 0.6, 1.0]
        animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn), CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear), CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        animation.duration = topAnimationDuration + bottomAnimationDuration
        animation.isRemovedOnCompletion = false
        
        bottomShadowLayer.add(animation, forKey: "shadow animation")
    }
    
    
    fileprivate func addBottomTileAnimation() {
        
        self.addSubview(self.newTextBottomView)
        newTextBottomView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        newTextBottomView.center = CGPoint(x: newTextBottomView.frame.width/2.0, y: newTextBottomView.frame.height)
        let bottomAnimation = CABasicAnimation(keyPath:"transform.rotation.x")
        
        bottomAnimation.duration = bottomAnimationDuration
        bottomAnimation.fromValue = M_PI_2
        bottomAnimation.toValue = 0.0
        bottomAnimation.isRemovedOnCompletion = false;
        bottomAnimation.fillMode = kCAFillModeForwards
        bottomAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        bottomAnimation.setValue("bottomAnimation", forKey: "id")
        bottomAnimation.delegate = self
        newTextBottomView.layer.add(bottomAnimation, forKey: "bottomRotation")
        
        var perspectiveTransform: CATransform3D = CATransform3DIdentity
        perspectiveTransform.m34 = 1.0 / -350;
        perspectiveTransform = CATransform3DRotate(perspectiveTransform, CGFloat(M_PI_2), 1.0, 0.0, 0.0);
        newTextBottomView.layer.transform = perspectiveTransform;
        
    }
    
    
    /// Stops all the animations and remove the animated snapshotViews
    func stopAnimations() {
        if self.newTextBottomView != nil {
            self.newTextBottomView.layer.removeAllAnimations()
            self.newTextBottomView.removeFromSuperview()
            self.newTextBottomView = nil
        }
        
        if self.previousTextTopView != nil {
            self.previousTextTopView.layer.removeAllAnimations()
            self.previousTextTopView.removeFromSuperview()
            self.previousTextTopView = nil
        }
        
        if self.previousTextBottomView != nil {
            self.previousTextBottomView.layer.removeAllAnimations()
            self.previousTextBottomView.removeFromSuperview()
            self.previousTextBottomView = nil
        }
    }
}


//MARK: - CAAnimationDelegate
extension FlipingLabel: CAAnimationDelegate {
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            //if the top animation is over, we start the bottom tile animation
            //(the one that will cover the old text tile)
            if anim.value(forKey: "id") as! String == "topAnimation" {
                self.addBottomTileAnimation()
//                canRemoveBottomView = true
            }
            else if anim.value(forKey: "id") as! String == "bottomAnimation" {
//                if canRemoveBottomView {
//                    canRemoveBottomView = false
                
                //clip to bounds back to yes if you have shadows
                    clipsToBounds = true;
                    newTextBottomView.removeFromSuperview()
                    newTextBottomView = nil
                    
                    previousTextBottomView.removeFromSuperview()
                    previousTextBottomView = nil
                    
                    previousTextTopView.removeFromSuperview()
                    previousTextTopView = nil
//                }
            }
        }
    }
    
}
