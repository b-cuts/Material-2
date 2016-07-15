/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

public class Material {
    /// A reference to the UIView.
    internal weak var view: UIView?
    
    /**
     Initializer that takes in a UIView.
     - Parameter view: A UIView reference.
     */
    internal init(view: UIView?) {
        self.view = view
    }
    
    /// A preset value for Depth.
    public var depthPreset: DepthPreset {
        get {
            return depth.preset
        }
        set(value) {
            depth.preset = value
        }
    }

    /// Grid reference.
    public var depth: Depth {
        didSet {
            guard let v = view else {
                return
            }
            
            v.layer.shadowOffset = depth.offset.asSize
            v.layer.shadowOpacity = depth.opacity
            v.layer.shadowRadius = depth.radius
        }
    }
}

/// A memory reference to the Depth instance for UIView extensions.
private var MaterialKey: UInt8 = 0

/// Grid extension for UIView.
public extension UIView {
    /// Material Reference.
    private var material: Material {
        get {
            return AssociatedObject(base: self, key: &MaterialKey) {
                return Material(view: self)
            }
        }
        set(value) {
            AssociateObject(base: self, key: &MaterialKey, value: value)
        }
    }
    
    /// A property that accesses the backing layer's shadowColor.
    @IBInspectable
    public var shadowColor: UIColor? {
        get {
            guard let v = layer.shadowColor else {
                return nil
            }
            
            return UIColor(cgColor: v)
        }
        set(value) {
            layer.shadowColor = value?.cgColor
        }
    }
    
    /// A property that accesses the backing layer's shadowOffset.
    @IBInspectable
    public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set(value) {
            layer.shadowOffset = value
        }
    }
    
    /// A property that accesses the backing layer's shadowOpacity.
    @IBInspectable
    public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set(value) {
            layer.shadowOpacity = value
        }
    }
    
    /// A property that accesses the backing layer's shadowRadius.
    @IBInspectable
    public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set(value) {
            layer.shadowRadius = value
        }
    }
    
    /// A property that accesses the backing layer's shadowPath.
    @IBInspectable
    public var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set(value) {
            layer.shadowPath = value
        }
    }
    
    /// A property that accesses the layer.borderWith.
    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set(value) {
            layer.borderWidth = value
        }
    }
    
    /// A property that accesses the layer.borderColor property.
    @IBInspectable
    public var borderColor: UIColor? {
        get {
            guard let v = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: v)
        }
        set(value) {
            layer.borderColor = value?.cgColor
        }
    }
    
    /// A property that accesses the layer.position property.
    @IBInspectable
    public var position: CGPoint {
        get {
            return layer.position
        }
        set(value) {
            layer.position = value
        }
    }
    
    /// A property that accesses the layer.zPosition property.
    @IBInspectable
    public var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        set(value) {
            layer.zPosition = value
        }
    }
    
    /**
     A method that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    public func animate(animation: CAAnimation) {
        animation.delegate = self
        if let a = animation as? CABasicAnimation {
            a.fromValue = (nil == layer.presentation() ? layer : layer.presentation()!).value(forKeyPath: a.keyPath!)
        }
        if let a = animation as? CAPropertyAnimation {
            layer.add(a, forKey: a.keyPath!)
        } else if let a = animation as? CAAnimationGroup {
            layer.add(a, forKey: nil)
        } else if let a = animation as? CATransition {
            layer.add(a, forKey: kCATransition)
        }
    }
    
    /**
     A delegation method that is executed when the backing layer stops
     running an animation.
     - Parameter animation: The CAAnimation instance that stopped running.
     - Parameter flag: A boolean that indicates if the animation stopped
     because it was completed or interrupted. True if completed, false
     if interrupted.
     */
    public override func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        if let a = animation as? CAPropertyAnimation {
            if let b = a as? CABasicAnimation {
                if let v = b.toValue {
                    if let k = b.keyPath {
                        layer.setValue(v, forKeyPath: k)
                        layer.removeAnimation(forKey: k)
                    }
                }
            }
        } else if let a = animation as? CAAnimationGroup {
            for x in a.animations! {
                animationDidStop(x, finished: true)
            }
        }
    }
}
