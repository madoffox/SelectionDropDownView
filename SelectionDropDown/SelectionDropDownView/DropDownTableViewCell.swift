//
//  DropDownTableViewCell.swift
//  SelectionDropDown
//
//  Created by Admin on 26.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol DropDownTableViewDelegate: class{
    func tableView(_ tableView:UITableView, didSelectDropDownCellAtIndexPath indexPath:IndexPath)
    func tableView(_ tableView:UITableView, updateLayerOptionsAndDeleteCellAt indexPath:IndexPath)
}

class DropDownTableViewCell: UITableViewCell {
    
    weak var delegate:DropDownTableViewDelegate!
    
    var tableView:UITableView?
    
    open var rippleColor: UIColor = .purple {
        didSet {
            rippleView.backgroundColor = rippleColor
        }
    }
    
    open var rippleBackgroundColor: UIColor = .clear {
        didSet {
            rippleBackgroundView.backgroundColor = rippleBackgroundColor
        }
    }
    
    open var nameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Sample Item"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
        
    }()

    private let rippleView = UIView()
    
    private let rippleBackgroundView = UIView()
    
    private var rippleMask: CAShapeLayer? {
        get {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
            return maskLayer
        }
    }

    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupRipple()
        setupLabel()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        addSubview(nameLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-16-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }

    private func setupRipple() {
        setupRippleView()
        
        rippleBackgroundView.backgroundColor = rippleBackgroundColor
        rippleBackgroundView.frame = bounds
        rippleBackgroundView.addSubview(rippleView)
        rippleBackgroundView.alpha = 0
        addSubview(rippleBackgroundView)
    }
    
    private func setupRippleView() {
        let size: CGFloat = bounds.width * 2
        let x: CGFloat = (bounds.width/2) - (size/2)
        let y: CGFloat = (bounds.height/2) - (size/2)
        let corner: CGFloat = size/2
        
        rippleView.backgroundColor = rippleColor
        rippleView.frame = CGRect(x: x, y: y, width: size, height: size)
        rippleView.layer.cornerRadius = corner
    }
    
    open func makeBeautifulEffect(indexPath:IndexPath) {
        let defaultFrame = self.frame
        self.frame = CGRect(x: defaultFrame.minX, y: defaultFrame.minY, width: 0, height: defaultFrame.height)
        UIView.animate(withDuration: 0.15, delay: TimeInterval(CGFloat(indexPath.row)*0.075), options: [.curveEaseOut], animations: {
            self.frame = defaultFrame
            self.alpha = 1
        })
    }
    
    private func startAnimation(with touch: UITouch) {
        
        
        let size: CGFloat = max((bounds.width - touch.location(in: self).x)*2 + 20, touch.location(in: self).x*2 + 20)
        rippleView.frame = CGRect(x: rippleView.frame.minX, y: rippleView.frame.minY, width: size, height: size)
        rippleView.layer.cornerRadius = size/2

        rippleView.center = touch.location(in: self)

        
      /*  UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            
        }, completion: nil)*/
        
        rippleView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.allowUserInteraction],
                       animations: {
                        self.rippleBackgroundView.alpha = 1
                        self.rippleView.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
  
    
    private func endAnimation(willDeleteCell: Bool) {
        
        if(willDeleteCell){
            guard let indexPath = self.tableView?.indexPath(for: self) else {return}
            self.delegate.tableView(self.tableView!, didSelectDropDownCellAtIndexPath: indexPath)
            self.isUserInteractionEnabled = false
        }
        
        
        
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.rippleBackgroundView.alpha = 1
        }, completion: {(success: Bool) -> () in
            
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                self.rippleBackgroundView.alpha = 0
                
                if(willDeleteCell){
                    self.backgroundColor = self.backgroundColor?.withAlphaComponent(0)
                    self.nameLabel.alpha = 0
                }
                self.rippleView.layer.cornerRadius = self.rippleView.frame.height*3/2
                self.rippleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: {(success: Bool) -> () in
                self.rippleView.transform = CGAffineTransform.identity
                if(willDeleteCell){
                    self.deleteCell()
                    
                    
                }
            })
        })
    }
    
    private func deleteCell() {
        guard let indexPath = self.tableView!.indexPath(for: self) else {return}
        delegate.tableView(self.tableView!, updateLayerOptionsAndDeleteCellAt: indexPath)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            startAnimation(with: touch)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endAnimation(willDeleteCell: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endAnimation(willDeleteCell: true)
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        setupRippleView()
        
        rippleBackgroundView.layer.frame = bounds
        rippleBackgroundView.layer.mask = rippleMask
    }
    
}


