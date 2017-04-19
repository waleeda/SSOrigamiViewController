//
//  ViewController.swift
//  CurtainTransition
//
//  Created by waleed azhar on 2017-04-18.
//  Copyright © 2017 waleed azhar. All rights reserved.
//

import UIKit

class OragamiViewController: UIViewController {

    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return childViewControllers[0]
    }
    
    private var rootVC:UIViewController?
    private var baseVC: UIViewController?
    
    private var root:UIView
    {
        return (rootVC?.view)!
    }
    
    private var base:UIView
    {
        return (baseVC?.view)!
    }
    
    private var cW:CGFloat = UIScreen.main.bounds.width
    private var shadeSize:CGSize? = CGSize.zero
    private var curtainLayer:CATransformLayer?
    private var shades:[CALayer] = []
    private var shadeImages:[CGImage] = []
    private var rightPan:UIScreenEdgePanGestureRecognizer!
    private var leftPan:UIScreenEdgePanGestureRecognizer!
    private var folds: Int = 2
    private var minSize = CGSize(width: UIScreen.main.bounds.width/2, height: 0)
    private let closedSize = CGSize(width: 40, height: 0)
  
    convenience init(curtain : UIViewController, base :UIViewController, folds: Int )
    {
        guard folds >= 2 else{ fatalError("folds")}
        self.init()
        self.rootVC = curtain
        self.baseVC = base
        self.addChildViewController(curtain)
        self.addChildViewController(base)
        self.folds = folds
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        rightPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panRight(g:)))
        rightPan.edges = .right
        view.addGestureRecognizer(rightPan)
        leftPan = UIScreenEdgePanGestureRecognizer(target: self, action:#selector(panLeft(g:)))
        leftPan.edges = .left
        view.addGestureRecognizer(leftPan)
        leftPan.isEnabled = false
        addRoot()
        addBase()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        makeShadeImages(amount: folds)
        makeLayers()
        view.layer.addSublayer(self.curtainLayer!)
    }
    
    private func addRoot()
    {
        rootVC?.view.frame = view.bounds
        rootVC?.view.layer.zPosition = -1000
        view.addSubview((rootVC?.view)!)
        rootVC?.didMove(toParentViewController: self)
    }
    
    private func addBase()
    {
        baseVC?.view.frame = view.bounds
        baseVC?.view.layer.zPosition = -1000
        view.insertSubview((baseVC?.view)!, at: 0)
        baseVC?.didMove(toParentViewController: self)
    }
    
    
    func open()
    {
        self.curtainLayer?.isHidden = false
        root.isHidden = true
        cW = 5
        end()
    }
    
    func close() {
        cW = UIScreen.main.bounds.width
        end()
    }
    
    @objc private  func panLeft(g:UIScreenEdgePanGestureRecognizer)
    {
        switch g.state
        {
            case .began:
                root.isHidden = true
                self.curtainLayer?.isHidden = false
            case .changed:
                cW = g.location(in: view).x
                animate()
            case .ended:
                end()
                
            default:
                ""
        }
    }
    
    @objc private  func panRight(g:UIScreenEdgePanGestureRecognizer)
    {
        switch g.state
        {
            case .began:
                root.isHidden = true
                self.curtainLayer?.isHidden = false
            case .changed:
                cW = g.location(in: view).x
                animate()
            case .ended:
                end()
            default:
                ""
        }
    }
    
    private func animate()
    {
        let wt = cW/CGFloat(shades.count)
        let a = ((shadeSize?.width)! - wt)/2.0
        let percent = ((UIScreen.main.bounds.width - cW) / UIScreen.main.bounds.width)
        print(percent)
        for (i,s) in shades.enumerated(){
            var rad = acos(wt/(shadeSize?.width)!)
            let xOffSet:CGFloat = a + (CGFloat(i) * (a + a))
            if (i%2 == 1){ rad = (rad) * CGFloat(-1.0)}
            s.zPosition = -10
            s.sublayers?[0].opacity = Float(percent)*0.2 + 0.20
            s.transform = CATransform3DConcat(CATransform3DIdentity,CATransform3DConcat(CATransform3DMakeRotation(rad, 0, 1, 0),
                                                                                        CATransform3DMakeTranslation(-xOffSet , 0, 0)))
        }
    }

    private func end()
    {
        if cW <= minSize.width {
            rightPan.isEnabled = false
            leftPan.isEnabled = true
            animateOpen()
        } else {
            rightPan.isEnabled = true
            leftPan.isEnabled = false
            animateClose()
        }
    }
    
    private func animateOpen()
    {
        cW = closedSize.width
        animate()
    }
    
    private func animateClose()
    {
        
        for (i,s) in shades.enumerated(){
            s.zPosition = 0
            s.transform = CATransform3DIdentity
            s.sublayers?[0].opacity = 0
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:
            {
                self.curtainLayer?.isHidden = true
                self.root.isHidden = false
            })
        
    }
    
    private func makeShadeImages(amount: Int)
    {
        let r = UIGraphicsImageRenderer(bounds: view.bounds)
        
        let ima = r.image
        { (_) in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        }

        var c = ima.cgImage
        var x:CGFloat = 0
        let y:CGFloat = 0
        let h = view.frame.height * UIScreen.main.scale
        let w = UIScreen.main.scale * (view.frame.width / CGFloat(amount))
    
        func makeCropRect(x2:CGFloat) -> CGRect
        {
            return CGRect(x: x2, y: y, width: w, height: h)
        }
        
        let dw = w
        
        for _ in 0..<amount
        {
            let crop = c!.cropping(to: CGRect(x: x, y: 0, width: w, height: h))
            if let cIm = crop
            {
                shadeImages.append(cIm)
            }
            x = x + dw
        }
        
        guard shadeImages.count == amount else
        {
            fatalError("Too few shade CGImages created")
        }
    }
    
    private func makeLayers()
    {
        var backLayer = CATransformLayer()
        backLayer.frame = view.bounds
        self.curtainLayer = backLayer

        var transform = CATransform3DIdentity
        transform.m34 = -1.0/1000.0
        backLayer.sublayerTransform = transform

        var x:CGFloat = 0
        let y:CGFloat = 0
        let h = view.frame.height
        let w = (view.frame.width / CGFloat(shadeImages.count))
        
        func makeRect(x2:CGFloat) -> CGRect
        {
            return CGRect(x: x2, y: y, width: w, height: h)
        }
        
        self.shadeSize = makeRect(x2: x).size
        
        for (i,image) in shadeImages.enumerated(){
            
            let layer = CALayer()
            layer.frame = makeRect(x2: x)
            layer.contents = image
            layer.contentsScale = UIScreen.main.scale
            layer.zPosition = -10
            let shadow = CAGradientLayer()
            shadow.frame = layer.bounds
            shadow.backgroundColor = UIColor.white.cgColor
            shadow.colors = [UIColor.black.cgColor,UIColor.clear.cgColor]
            shadow.opacity = 0
  
            if (i%2 == 1)
            {
                shadow.startPoint = CGPoint(x:0, y:0.5);
                shadow.endPoint = CGPoint(x:1, y:0.5);

            }else
            {
                shadow.startPoint = CGPoint(x:1,y: 0.5);
                shadow.endPoint = CGPoint(x:0,y: 0.5);
            }
            
            layer.addSublayer(shadow)
            backLayer.addSublayer(layer)
            shades.append(layer)
            
            
            x = x + w
        }
        
        guard shadeImages.count == shades.count else
        {
            fatalError("too few layers")
        }

    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

