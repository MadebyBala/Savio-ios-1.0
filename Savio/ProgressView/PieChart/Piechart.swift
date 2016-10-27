
import UIKit


public protocol PiechartDelegate {
    func setSubtitle(total: CGFloat, slice: Piechart.Slice) -> String
    func setInfo(total: CGFloat, slice: Piechart.Slice) -> String
}



/**
 * Piechart
 */
public class Piechart: UIControl {
    
    /**
     * Slice
     */
    public struct Slice {
        public var color: UIColor!
        public var value: CGFloat!
        public var text: String!
    }
    
    /**
     * Radius
     */
    public struct Radius {
        public var outer: CGFloat = 125
        
        public var inner: CGFloat = 100
    
    }
    
    /**
     * private
     */
    private var total: CGFloat!
    
    
    /**
     * public
     */
    public var radius: Radius = Radius()
    public var activeSlice: Int = -1
    public var delegate: PiechartDelegate?
    
    
    public var slices: [Slice] = [] {
        didSet {
            total = 0
            for slice in slices {
                total = slice.value + total
            }
        }
    }
    
    
    
    /**
     * methods
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        self.addTarget(self, action: Selector("click"), forControlEvents: .TouchUpInside)
        
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        var startValue: CGFloat = 0
        var startAngle: CGFloat = 0
        var endValue: CGFloat = 0
        var endAngle: CGFloat = 0
        
        for (index, slice) in slices.enumerate() {
            
            startAngle = (startValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            endValue = startValue + (slice.value / self.total)
            endAngle = (endValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            
            //Create Path
            let path = UIBezierPath()
            path.moveToPoint(center)
            
            // create center donut hole
            let innerPath = UIBezierPath()
            //innerPath.moveToPoint(center)
            
            if index == activeSlice {
                path.addArcWithCenter(center, radius: radius.outer + 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                innerPath.addArcWithCenter(center, radius: radius.inner - 2.0 , startAngle: startAngle, endAngle: endAngle, clockwise: true)
            }
            else if index == slices.count - 1 && slice.text == "Error"{
                //this will be the last slice
                path.addArcWithCenter(center, radius: radius.outer - 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                innerPath.addArcWithCenter(center, radius: radius.inner + 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            }
            else {
                
                path.addArcWithCenter(center, radius: radius.outer, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                innerPath.addArcWithCenter(center, radius: radius.inner, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                
            }
            
            let color = slice.color
            color.setFill()
            path.fill()
            
            UIColor.whiteColor().setFill()
            innerPath.fill()
            
            // add white border to slice
            // increase start value for next slice
            startValue += slice.value / self.total
        }
        
    }
    
    
    func click()
    {
        
    }
    func click(index:Int) {
   
        activeSlice = index
        
        setNeedsDisplay()
    }
    
}