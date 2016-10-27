import UIKit
import QuartzCore

// delegate method
public protocol LineChartDelegate {
//    func didSelectDataPoint(x: CGFloat, yValues: [CGFloat])
//    func setValuesForSlider(min: CGFloat, max: CGFloat)
//    func scrollLineDragged(x: CGFloat)
    func chartVerticalLineDrawingCompleted()
}

/**
 * LineChart
 */
public class LineChart: UIView {
    
    /**
    * Helpers class
    */
    private class Helpers {
        
        /**
        * Convert hex color to UIColor
        */
        private class func UIColorFromHex(hex: Int) -> UIColor {
            let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
            let blue = CGFloat((hex & 0xFF)) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
        /**
        * Lighten color.
        */
        private class func lightenUIColor(color: UIColor) -> UIColor {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return UIColor(hue: h, saturation: s, brightness: b * 1.5, alpha: a)
        }
    }
    
    public struct Labels {
        public var visible: Bool = true
        public var values: [String] = []
    }
    
    public struct Grid {
        public var visible: Bool = true
        public var count: CGFloat = 10
        // #eeeeee
        public var color: UIColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    }
    
    public struct Axis {
        public var visible: Bool = true
        // #607d8b
        public var color: UIColor = UIColor(red: 96/255.0, green: 125/255.0, blue: 139/255.0, alpha: 1)
        public var inset: CGFloat = 30
    }
    
    public struct Coordinate {
        // public
        public var labels: Labels = Labels()
        public var grid: Grid = Grid()
        public var axis: Axis = Axis()
        
        // private
        private var linear: LinearScale!
        private var scale: ((CGFloat) -> CGFloat)!
        private var invert: ((CGFloat) -> CGFloat)!
        private var ticks: (CGFloat, CGFloat, CGFloat)!
    }
    
    public struct Animation {
        public var enabled: Bool = true
        public var duration: CFTimeInterval = 1
    }
    
    public struct Dots {
        public var visible: Bool = true
        public var color: UIColor = UIColor.whiteColor()
        public var innerRadius: CGFloat = 6
        public var outerRadius: CGFloat = 10
        public var innerRadiusHighlighted: CGFloat = 8
        public var outerRadiusHighlighted: CGFloat = 12
    }
    
    // default configuration
    public var area: Bool = true
    public var animation: Animation = Animation()
    public var dots: Dots = Dots()
    public var lineWidth: CGFloat = 1
    

    private var colorGraphLine: UIColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
    private var colorGraphDot: UIColor = UIColor.init(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    private var colorGraphUnderArea: UIColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
    private var colorGraphScrollLine: UIColor = UIColor.init(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    private var colorGraphProgressView: UIColor = UIColor.init(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    
    
    public var _planTitle: String = ""

    
    public var planTitle: String {
        get {
            return _planTitle
        }
        set(newValue) {
            _planTitle = newValue
            
            if _planTitle == "Group" {
                
                let blueColor: UIColor = UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1)
                self.colorGraphLine = blueColor
                self.colorGraphDot = blueColor
                self.colorGraphUnderArea = blueColor
                self.colorGraphScrollLine = blueColor
                self.colorGraphProgressView = blueColor
                
            } else {
                
                let brownColor: UIColor = UIColor(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
                self.colorGraphLine = brownColor
                self.colorGraphDot = brownColor
                self.colorGraphUnderArea = brownColor
                self.colorGraphScrollLine = brownColor
                self.colorGraphProgressView = brownColor
            }
        }
    }
    
    public var x: Coordinate = Coordinate()
    public var y: Coordinate = Coordinate()
    public var graphView: UIView = UIView()
    public var graphHeight: CGFloat = 0
    public var maximumValue: CGFloat = 0
    public var minimumValue: CGFloat = 0
    var scrollViewReference: UIScrollView  = UIScrollView()
     var thumbImgView = UIImageView()
    var graphMovingVerticalLine = UIView()

    // values calculated on init
    private var drawingHeight: CGFloat = 0 {
        didSet {
            let max = getMaximumValue()
            let min = getMinimumValue()
            y.linear = LinearScale(domain: [min, max], range: [0, drawingHeight])
            y.scale = y.linear.scale()
            y.ticks = y.linear.ticks(Int(y.grid.count))
        }
    }
    private var drawingWidth: CGFloat = 0 {
        didSet {

            let data = dataStore[0]
            x.linear = LinearScale(domain: [0.0, CGFloat(data.count - 1)], range: [0, drawingWidth])
            x.scale = x.linear.scale()
            x.invert = x.linear.invert()
            x.ticks = x.linear.ticks(Int(x.grid.count))
        }
    }
    
    public var delegate: LineChartDelegate?
    
    // data stores
    private var dataStore: [[CGFloat]] = []
    private var dotsDataStore: [[DotCALayer]] = []
    private var lineLayerStore: [CAShapeLayer] = []
    
    private var removeAll: Bool = false
    
    // category10 colors from d3 - https://github.com/mbostock/d3/wiki/Ordinal-Scales
    public var colors: [UIColor] = [
        UIColor(red: 0.121569, green: 0.466667, blue: 0.705882, alpha: 1),
        UIColor(red: 1, green: 0.498039, blue: 0.054902, alpha: 1),
        UIColor(red: 0.172549, green: 0.627451, blue: 0.172549, alpha: 1),
        UIColor(red: 0.839216, green: 0.152941, blue: 0.156863, alpha: 1),
        UIColor(red: 0.580392, green: 0.403922, blue: 0.741176, alpha: 1),
        UIColor(red: 0.54902, green: 0.337255, blue: 0.294118, alpha: 1),
        UIColor(red: 0.890196, green: 0.466667, blue: 0.760784, alpha: 1),
        UIColor(red: 0.498039, green: 0.498039, blue: 0.498039, alpha: 1),
        UIColor(red: 0.737255, green: 0.741176, blue: 0.133333, alpha: 1),
        UIColor(red: 0.0901961, green: 0.745098, blue: 0.811765, alpha: 1)
    ]
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor(colorLiteralRed: 2536.0/255.0, green: 246.0/255.0, blue: 235.0/255.0, alpha: 1)
        self.backgroundColor = UIColor.clearColor()
    }

    convenience init() {
        self.init(frame: CGRectZero)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override public func drawRect(rect: CGRect) {
        
        graphHeight = self.bounds.height

        if removeAll {
            let context = UIGraphicsGetCurrentContext()
            CGContextClearRect(context, rect)
            return
        }
        
        self.drawingHeight = graphHeight - (2 * y.axis.inset)
        self.drawingWidth = self.bounds.width - (2 * x.axis.inset)
        
        // remove all labels
        for view: AnyObject in self.subviews {
            view.removeFromSuperview()
        }
        
        // remove all lines on device rotation
        for lineLayer in lineLayerStore {
            lineLayer.removeFromSuperlayer()
        }
        lineLayerStore.removeAll()
        
        // remove all dots on device rotation
        for dotsData in dotsDataStore {
            for dot in dotsData {
                dot.removeFromSuperlayer()
            }
        }
        dotsDataStore.removeAll()
        
        // draw grid
        if x.grid.visible && y.grid.visible { drawGrid() }
        
        // draw axes
        if x.axis.visible && y.axis.visible { drawAxes() }
        
        // draw labels
        if x.labels.visible { drawXLabels() }
        if y.labels.visible { drawYLabels() }
        
        // draw lines
        for (lineIndex, _) in dataStore.enumerate() {
            
            drawLine(lineIndex)
            
            // draw dots
            if dots.visible { drawDataDots(lineIndex) }
            
            // draw area under line chart
            if area { drawAreaBeneathLineChart(lineIndex) }
            
        }
        
        
        //draw liner line
        self.drawScrollLineForPoint(x.axis.inset)
    }
    
    func sliderValueChanged(slider: UISlider) {
        if  CGFloat(slider.value) >= x.axis.inset && CGFloat(slider.value) <=  self.drawingWidth + x.axis.inset {
            moveScrollLineForPoint(CGFloat(slider.value))
            let xValue = CGFloat(slider.value)
            let inverted = self.x.invert(xValue - x.axis.inset)
            let rounded = Int(round(Double(inverted)))
            setProgressForCircularFloatingProgressBar(rounded)
            let yValues: [CGFloat] = getYValuesForXValue(rounded)
            let firstValue = yValues.first
            if firstValue >= 0 {
                let stringValue: String = String.init(format: "%.0f", firstValue!)
                self.valueLabel.text = stringValue
            }
        }
    }
    
    /**
     * Get y value for given x value. Or return zero or maximum value.
     */
    private func getYValuesForXValue(x: Int) -> [CGFloat] {
        var result: [CGFloat] = []
        for lineData in dataStore {
            if x < 0 {
                result.append(lineData[0])
            } else if x > lineData.count - 1 {
                result.append(lineData[lineData.count - 1])
            } else {
                result.append(lineData[x])
            }
        }
        return result
    }
    
    
    
    /**
     * Handle touch events.
     */
//    private func handleTouchEvents(touches: NSSet!, event: UIEvent) {
//        if (self.dataStore.isEmpty) {
//            return
//        }
//        let point: AnyObject! = touches.anyObject()
//        let xValue = point.locationInView(self).x
//        let inverted = self.x.invert(xValue - x.axis.inset)
//        let rounded = Int(round(Double(inverted)))
//        let yValues: [CGFloat] = getYValuesForXValue(rounded)
//        highlightDataPoints(rounded)
//        delegate?.didSelectDataPoint(CGFloat(rounded), yValues: yValues)
//    }
//    
//    
    
    /**
     * Listen on touch end event.
     */
//    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        handleTouchEvents(touches, event: event!)
//    }
    
    
    
    /**
     * Listen on touch move event
     */
//    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//        handleTouchEvents(touches, event: event!)
//    }
//    
    
    
    /**
     * Highlight data points at index.
     */
    private func highlightDataPoints(index: Int) {
        for (lineIndex, dotsData) in dotsDataStore.enumerate() {
            // make all dots white again
            for dot in dotsData {
                dot.backgroundColor = dots.color.CGColor
            }
            // highlight current data point
            var dot: DotCALayer
            if index < 0 {
                dot = dotsData[0]
            } else if index > dotsData.count - 1 {
                dot = dotsData[dotsData.count - 1]
            } else {
                dot = dotsData[index]
            }
//            dot.backgroundColor = Helpers.lightenUIColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)).CGColor
            
        }
    }
    
    
    
    func setProgressForCircularFloatingProgressBar(index: Int)  {
        var data: [CGFloat] = self.dataStore[0]
        if data.count > 0 {
            
            let currentValue: CGFloat = data[index] as CGFloat
            if currentValue >= 0 {
                let progressValue = (360.0  / self.maximumValue) * currentValue
                progress.angle = Double(progressValue)
            }
        }
    }
    /**
     * Draw small dot at every data point.
     */
    private func drawDataDots(lineIndex: Int) {
        var dotLayers: [DotCALayer] = []
        var data = self.dataStore[lineIndex]
        
        self.setProgressForCircularFloatingProgressBar(0)
        for index in 0..<data.count {
            
            if data[index] < 0 {
                return
            }
            let xValue = self.x.scale(CGFloat(index)) + x.axis.inset - dots.outerRadius/2
            let yValue = graphHeight - self.y.scale(data[index]) - y.axis.inset - dots.outerRadius/2
            
            // draw custom layer with another layer in the center
            let dotLayer = DotCALayer()
            dotLayer.dotInnerColor = self.colorGraphDot//colors[lineIndex]
            dotLayer.innerRadius = dots.innerRadius
            
            if index % 2 == 0  {
                dotLayer.backgroundColor = UIColor.clearColor().CGColor
            } else {
                dotLayer.backgroundColor = UIColor(colorLiteralRed: 85.0/255.0, green: 87.0/255.0, blue: 86.0/255.0, alpha: 1).CGColor

            }
            
            
            dotLayer.cornerRadius = dots.outerRadius / 2
            dotLayer.frame = CGRect(x: xValue, y: yValue, width: dots.outerRadius, height: dots.outerRadius)
            self.layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
            // animate opacity
            if animation.enabled {
                let anim = CABasicAnimation(keyPath: "opacity")
                anim.duration = animation.duration
                anim.fromValue = 0
                anim.toValue = 1
                dotLayer.addAnimation(anim, forKey: "opacity")
            }
            
        }
        dotsDataStore.append(dotLayers)
    }
    
    
    
    public var valueLabel: UILabel = UILabel()
    let widthOfScrollingLineView: CGFloat = 34.0

    let progress = KDCircularProgress(frame: CGRect(x:  0, y: -17.0, width: 34, height: 34))
    
    
    func scrollLineMoved(gesture: UIPanGestureRecognizer) {
        let  transalation = gesture.locationInView(self)
        if  CGFloat(transalation.x) >= x.axis.inset && CGFloat(transalation.x) <=  self.drawingWidth + x.axis.inset {
//            self.delegate?.scrollLineDragged(transalation.x)
            moveScrollLineForPoint(CGFloat(transalation.x))
            let xValue = CGFloat(transalation.x)
            let inverted = self.x.invert(xValue - x.axis.inset)
            let rounded = Int(round(Double(inverted)))
            setProgressForCircularFloatingProgressBar(rounded)
            let yValues: [CGFloat] = getYValuesForXValue(rounded)
            let firstValue = yValues.first
            if firstValue >= 0 {
                let stringValue: String = String.init(format: "%.0f", firstValue!)
                self.valueLabel.text = stringValue
            }
        }
    }
    
    func drawSliderTrack() {
        let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let trackImage = UIImage(named: "stats-slider-bar")?.resizableImageWithCapInsets(myInsets)
        let width = self.frame.size.width - x.axis.inset
        
        let trackImageView = UIImageView(frame: CGRect(x: x.axis.inset, y: self.frame.size.height , width: width, height: 4))
        trackImageView.image = trackImage
        self.addSubview(trackImageView)
    }
    
    func drawScrollLineForPoint(a1: CGFloat) {
        //add track images
        self.drawSliderTrack()

        graphView = UIView(frame: CGRect(x: a1 - widthOfScrollingLineView / 2.0, y: x.axis.inset, width: 40, height: self.frame.size.height ))
        graphView.backgroundColor = UIColor.clearColor()
        
        let data = self.dataStore[0]

        
        self.valueLabel.frame = CGRect(x: 4.0 , y: widthOfScrollingLineView / 2.0 - 2.0, width: widthOfScrollingLineView - 10.0, height: 10)
        var firstValue = data.first
        if firstValue < 0 {
            firstValue = 0
        }
        let stringValue: String = String.init(format: "%.0f", firstValue!)

        self.valueLabel.text = stringValue
        self.valueLabel.font =  UIFont(name: kMediumFont, size: 7)
        self.valueLabel.textAlignment = .Center
        
        //draw line
        graphMovingVerticalLine  = UIView(frame: CGRect(x: (widthOfScrollingLineView / 2.0) + 0.25                   , y: 0, width: 1, height: self.frame.size.height - 30))
        graphMovingVerticalLine.backgroundColor = self.colorGraphScrollLine
        graphView.addSubview(graphMovingVerticalLine)
        self.addSubview(graphView)
        
        //draw thumbImage 
        thumbImgView = UIImageView(frame: CGRect(x: 14, y: self.frame.size.height - 32.0, width: 8, height: 9))
        graphView.addSubview(thumbImgView)


        //white center view
        let cvRadius: CGFloat = 12.5
        let cvX: CGFloat = progress.frame.width / 2.0 - cvRadius
        let cvY: CGFloat = progress.frame.height / 2.0 - cvRadius
        let centerView = UIView(frame: CGRect(origin: CGPoint(x: cvX, y:cvY), size: CGSize(width: 2 * cvRadius, height: 2 * cvRadius)))
        centerView.layer.cornerRadius = centerView.frame.width / 2.0
        centerView.backgroundColor = UIColor.whiteColor()
        progress.addSubview(centerView)

        
        
        //image view
        let imgHeight: CGFloat = 7
        let imageView: UIImageView = UIImageView(frame: CGRect(x: (widthOfScrollingLineView - imgHeight) / 2, y: imgHeight, width: imgHeight, height: imgHeight))
        imageView.image = UIImage(named: "target-score-crown")
        
        //progress view
        self.progress.addSubview(imageView)
        progress.startAngle = -90
        progress.progressThickness = 0.4
        progress.trackThickness = 0.2
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .NoGlow
        progress.setColors(self.colorGraphProgressView)
        progress.trackColor = UIColor.init(red: 232.0/255.0, green: 236.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        graphView.addSubview(progress)
        progress.addSubview(valueLabel)

        delegate?.chartVerticalLineDrawingCompleted()
        
        // add getsture recogniszer
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("scrollLineMoved:"))
        graphView.addGestureRecognizer(gesture)
    }
    
    func circlePathWithCenter(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath()
        circlePath.addArcWithCenter(center, radius: radius, startAngle: -CGFloat(M_PI), endAngle: -CGFloat(M_PI/2), clockwise: true)
        circlePath.addArcWithCenter(center, radius: radius, startAngle: -CGFloat(M_PI/2), endAngle: 0, clockwise: true)
        circlePath.addArcWithCenter(center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI/2), clockwise: true)
        circlePath.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI/2), endAngle: CGFloat(M_PI), clockwise: true)
        circlePath.closePath()
        return circlePath
    }

     func moveScrollLineForPoint(a1: CGFloat) {
        graphView.frame = CGRect(x: a1 - widthOfScrollingLineView / 2, y: x.axis.inset, width: self.graphView.frame.width, height: self.frame.size.height)
    }

    /**
     * Draw x and y axis.
     */
    private func drawAxes() {
        let height = graphHeight
        let width = self.bounds.width
        let path = UIBezierPath()
        // draw x-axis
        x.axis.color.setStroke()
        let y0 = height - self.y.scale(0) - y.axis.inset
        path.moveToPoint(CGPoint(x: x.axis.inset, y: y0))
//        path.addLineToPoint(CGPoint(x: width - x.axis.inset, y: y0))
        path.addLineToPoint(CGPoint(x: width + x.axis.inset , y: y0))
        path.stroke()
        // draw y-axis
        y.axis.color.setStroke()
//        path.moveToPoint(CGPoint(x: x.axis.inset, y: height - y.axis.inset))
//        path.addLineToPoint(CGPoint(x: x.axis.inset, y: y.axis.inset))
//        path.stroke()
    }
    
    
    
    /**
     * Get maximum value in all arrays in data store.
     */
    private func getMaximumValue() -> CGFloat {
//        var max: CGFloat = 1
//        for data in dataStore {
//            let newMax = data.maxElement()!
//            if newMax > max {
//                max = newMax
//            }
//        }
        return self.maximumValue
    }
    
    
    
    /**
     * Get maximum value in all arrays in data store.
     */
    private func getMinimumValue() -> CGFloat {
//        var min: CGFloat = 0
//        for data in dataStore {
//            let newMin = data.minElement()!
//            if newMin < min {
//                min = newMin
//            }
//        }
        return self.minimumValue
    }
    
    
    /**
     * Draw line.
     */
    private func drawLine(lineIndex: Int) {
        
        var data = self.dataStore[lineIndex]
        

        let path = UIBezierPath()
        
        var xValue = self.x.scale(0) + x.axis.inset
        var yValue = graphHeight - self.y.scale(data[0]) - y.axis.inset
        path.moveToPoint(CGPoint(x: xValue, y: yValue))
        for index in 1..<data.count {
            if data[index]  >= 0 {
                xValue = self.x.scale(CGFloat(index)) + x.axis.inset
                yValue = graphHeight - self.y.scale(data[index]) - y.axis.inset
                path.addLineToPoint(CGPoint(x: xValue, y: yValue))
            }
        }
        
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.CGPath
        layer.strokeColor = self.colorGraphLine.CGColor //colors[lineIndex].CGColor
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        self.layer.addSublayer(layer)
        
        // animate line drawing
        if animation.enabled {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.duration = animation.duration
            anim.fromValue = 0
            anim.toValue = 1
            layer.addAnimation(anim, forKey: "strokeEnd")
        }
        
        // add line layer to store
        lineLayerStore.append(layer)
    }
    
    
    
    /**
     * Fill area between line chart and x-axis.
     */
    private func drawAreaBeneathLineChart(lineIndex: Int) {
        
        var data = self.dataStore[lineIndex]
        let path = UIBezierPath()
        
       
//        colors[lineIndex].colorWithAlphaComponent(0.2).setFill()
        self.colorGraphUnderArea.colorWithAlphaComponent(0.2).setFill()
        // move to origin
        path.moveToPoint(CGPoint(x: x.axis.inset, y: graphHeight - self.y.scale(0) - y.axis.inset))
        // add line to first data point
        path.addLineToPoint(CGPoint(x: x.axis.inset, y: graphHeight - self.y.scale(data[0]) - y.axis.inset))
        // draw whole line chart
        var lastIndex = 0
        for index in 1..<data.count {
            if data[index]  >= 0 {
                let x1 = self.x.scale(CGFloat(index)) + x.axis.inset
                let y1 = graphHeight - self.y.scale(data[index]) - y.axis.inset
                path.addLineToPoint(CGPoint(x: x1, y: y1))
                lastIndex = index
            }
        }
        // move down to x axis
        path.addLineToPoint(CGPoint(x: self.x.scale(CGFloat(lastIndex)) + x.axis.inset, y: graphHeight - self.y.scale(0) - y.axis.inset))
        // move to origin
        path.addLineToPoint(CGPoint(x: x.axis.inset, y: graphHeight - self.y.scale(0) - y.axis.inset))
        path.fill()
    }
    
    
    
    /**
     * Draw x grid.
     */
    private func drawXGrid() {
        x.grid.color.setStroke()
        let path = UIBezierPath()
        var x1: CGFloat
        let y1: CGFloat = graphHeight - y.axis.inset
        let y2: CGFloat = y.axis.inset
        let (start, stop, step) = self.x.ticks
        for var i: CGFloat = start; i <= stop; i += step {
            x1 = self.x.scale(i) + x.axis.inset
            path.moveToPoint(CGPoint(x: x1, y: y1))
            path.addLineToPoint(CGPoint(x: x1, y: y2))
        }
        path.stroke()
    }
    
    
    /**
     * Draw y grid.
     */
    private func drawYGrid() {
        self.y.grid.color.setStroke()
        let path = UIBezierPath()
        let x1: CGFloat = x.axis.inset
        let x2: CGFloat = self.bounds.width
        var y1: CGFloat
        var (start, stop, step) = self.y.ticks
        let drawIndex: CGFloat =  floor(( (stop - start) / step ) / 5.0)
        step *= drawIndex
        for var i: CGFloat = start; i <= stop; i += step {
            y1 = graphHeight - self.y.scale(i) - y.axis.inset
                path.moveToPoint(CGPoint(x: x1, y: y1))
                path.addLineToPoint(CGPoint(x: x2, y: y1))
        }
        path.stroke()
    }
    
    /**
     * Draw grid.
     */
    private func drawGrid() {
//        drawXGrid()
        drawYGrid()
    }
    
    /**
     * Draw x labels.
     */
    private func createXLabelText (index: Int) -> NSMutableAttributedString {
        let text = x.labels.values[index]
        let attributes: Dictionary = [NSFontAttributeName:UIFont(name: kMediumFont, size: 8)!]
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:4)

        switch index {
        case 0:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.appendAttributedString(superscript)
            break
            
        case 1:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.appendAttributedString(superscript)
            break
            
        case 2:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.appendAttributedString(superscript)
            break
            
        default:
            let superscript = NSMutableAttributedString(string: "th", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.appendAttributedString(superscript)
            break
            
        }
        attString.appendAttributedString(NSAttributedString(string: " month", attributes: attributes))
        
        return attString
    }
    
    private func drawXLabels() {
        let xAxisData = self.dataStore[0]
        let y = graphHeight - x.axis.inset + 4 // 4 added for giving space to supercript
        let (_, _, step) = x.linear.ticks(xAxisData.count)
        let width = x.scale(step)
     
        for (index, _) in xAxisData.enumerate() {
            let xValue = self.x.scale(CGFloat(index)) + x.axis.inset - (width / 2)
            let label = UILabel(frame: CGRect(x: xValue, y: y, width: width, height: x.axis.inset))
            if index == 0 {
                label.textAlignment = .Right
            }
            else  if index == xAxisData.count - 1 {
                label.textAlignment = .Left
            }
            else {
                label.textAlignment = .Center
            }
            
            if (x.labels.values.count != 0) {
                label.attributedText =  createXLabelText(index) //x.labels.values[index]
            } else {
                label.text = String(index)
            }

            self.addSubview(label)
        }
    }
    
    
    /**
     * Draw y labels.
     */
    private func drawYLabels() {
        var yValue: CGFloat
        var (start, stop, step) = self.y.ticks
        let drawIndex: CGFloat =  floor(( (stop - start) / step ) / 5.0)
        step *= drawIndex
        for var i: CGFloat = start; i <= stop; i += step {
            yValue = graphHeight - self.y.scale(i) - (y.axis.inset * 1.5)
            let label = UILabel(frame: CGRect(x: 2.0, y: yValue, width: y.axis.inset - 8.0, height: y.axis.inset))
            label.font = UIFont(name: kLightFont, size: 6)
            label.textAlignment = .Right
            label.text = String(Int(round(i)))
            label.backgroundColor = UIColor.clearColor()
            self.addSubview(label)
        }
    }
    
    /**
     * Add line chart
     */
    public func addLine(data: [CGFloat]) {
        self.dataStore.append(data)
        self.setNeedsDisplay()
    }
    
    
    
    /**
     * Make whole thing white again.
     */
    public func clearAll() {
        self.removeAll = true
        clear()
        self.setNeedsDisplay()
        self.removeAll = false
    }
    
    
    
    /**
     * Remove charts, areas and labels but keep axis and grid.
     */
    public func clear() {
        // clear data
        dataStore.removeAll()
        self.setNeedsDisplay()
    }
}



/**
 * DotCALayer
 */
class DotCALayer: CALayer {
    
    var innerRadius: CGFloat = 8
    var dotInnerColor = UIColor.blackColor()
    
    override init() {
        super.init()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        let inset = self.bounds.size.width - innerRadius
        let innerDotLayer = CALayer()
        innerDotLayer.frame = CGRectInset(self.bounds, inset/2, inset/2)
        innerDotLayer.backgroundColor = dotInnerColor.CGColor
        innerDotLayer.cornerRadius = innerRadius / 2
        self.addSublayer(innerDotLayer)
    }
    
}



/**
 * LinearScale
 */
public class LinearScale {
    
    var domain: [CGFloat]
    var range: [CGFloat]
    
    public init(domain: [CGFloat] = [0, 1], range: [CGFloat] = [0, 1]) {
        self.domain = domain
        self.range = range
    }
    
    public func scale() -> (x: CGFloat) -> CGFloat {
        return bilinear(domain, range: range, uninterpolate: uninterpolate, interpolate: interpolate)
    }
    
    public func invert() -> (x: CGFloat) -> CGFloat {
        return bilinear(range, range: domain, uninterpolate: uninterpolate, interpolate: interpolate)
    }
    
    public func ticks(m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTicks(domain, m: m)
    }
    
    private func scale_linearTicks(domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTickRange(domain, m: m)
    }
    
    private func scale_linearTickRange(domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        var extent = scaleExtent(domain)
        let span = extent[1] - extent[0]
        var step = CGFloat(pow(10, floor(log(Double(span) / Double(m)) / M_LN10)))
        let err = CGFloat(m) / span * step
        
        // Filter ticks to get closer to the desired count.
        if (err <= 0.15) {
            step *= 10
        } else if (err <= 0.35) {
            step *= 5
        } else if (err <= 0.75) {
            step *= 2
        }
        
        // Round start and stop values to step interval.
        let start = ceil(extent[0] / step) * step
        let stop = floor(extent[1] / step) * step + step * 0.5 // inclusive
        
        return (start, stop, step)
    }
    
    private func scaleExtent(domain: [CGFloat]) -> [CGFloat] {
        let start = domain[0]
        let stop = domain[domain.count - 1]
        return start < stop ? [start, stop] : [stop, start]
    }
    
    private func interpolate(a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat {
        var diff = b - a
        func f(c: CGFloat) -> CGFloat {
            return (a + diff) * c
        }
        return f
    }
    
    private func uninterpolate(a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat {
        var diff = b - a
        var re = diff != 0 ? 1 / diff : 0
        func f(c: CGFloat) -> CGFloat {
            return (c - a) * re
        }
        return f
    }
    
    private func bilinear(domain: [CGFloat], range: [CGFloat], uninterpolate: (a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat, interpolate: (a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat) -> (c: CGFloat) -> CGFloat {
        var u: (c: CGFloat) -> CGFloat = uninterpolate(a: domain[0], b: domain[1])
        var i: (c: CGFloat) -> CGFloat = interpolate(a: range[0], b: range[1])
        func f(d: CGFloat) -> CGFloat {
            return i(c: u(c: d))
        }
        return f
    }
    
}