//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import AVFoundation

class VisionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // ui elements
    private var imageView: UIImageView = UIImageView()
    private var prescriptionSlider: UISlider = UISlider()
    private var currentPrescriptionLabel: UILabel = UILabel()
    private var arButton: UIButton = UIButton()
    private var nextImageButton: UIButton = UIButton()
    private var controlBackground: UIView = UIView()
    
    /// currently simulating prescription
    private var prescription: Double = 0
    
    /// all images to display
    private var displayImages: [UIImage] = []
    /// currently displayed image
    private var currentImageIndex: Int = 0

    // width and height of screen
    private var width: CGFloat!
    private var height: CGFloat!
    
    // live camera properties
    private var displayingAR: Bool = false
    private var cameraSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func loadView() {
        displayImages = [UIImage(named: "applepark.png")!, UIImage(named: "wwdc.png")!, UIImage(named: "poster.png")!]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        view.backgroundColor = UIColor.white
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAll()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAll()
    }
    
    /// initialize all ui elements
    private func initAll() {
        width = self.view.frame.width
        height = self.view.frame.height
        
        initImageView()
        initControlBackground()
        initSlider()
        initLabel()
        initButtons()
        
        displayImage(displayImages[currentImageIndex], prescription: prescription)
    }
    
    /// update frames for all ui elements
    private func updateAll() {
        width = self.view.frame.width
        height = self.view.frame.height
        updateImageView()
        updateControlBackground()
        updateSlider()
        updateLabel()
        updateButtons()
    }
    
    private func initImageView() {
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
    }
    
    private func updateImageView() {
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    /// Displays the given image
    ///
    /// - Parameter largeImage: image to display
    private func displayImage(_ image: UIImage, prescription: Double) {
        let largeImage = image
        let heightRatio = largeImage.size.height / largeImage.size.width
        let resizedImage = largeImage.withSize(newSize: CGSize(width: 2 * width, height: 2 * heightRatio * width))
        let prescriptionImage = resizedImage.withPrescription(perscription: prescription, original: resizedImage.size)
        imageView.image = prescriptionImage
    }
    
    private func initControlBackground() {
//        controlBackground.layer.cornerRadius = 20
//        controlBackground.layer.masksToBounds = true
        controlBackground.backgroundColor = darkGrayColor
        view.addSubview(controlBackground)
    }
    
    private func updateControlBackground() {
        controlBackground.frame = CGRect(x: 0, y: height * 0.9, width: width, height: height * 0.15)
        
    }
    
    /// initialize the slider
    private func initSlider() {
        prescriptionSlider.maximumValue = 4
        prescriptionSlider.minimumValue = 0
        prescriptionSlider.tintColor = offwhiteColor
        prescriptionSlider.value = 0
        prescriptionSlider.maximumTrackTintColor = UIColor.darkGray
        prescriptionSlider.addTarget(self, action: #selector(updatePrescription(sender:)), for: .valueChanged)
        view.addSubview(prescriptionSlider)
    }
    
    private func updateSlider() {
        let widthScale: CGFloat = 0.4
        prescriptionSlider.frame = CGRect(x: CGFloat(0.5 - widthScale / 2) * width, y: height * 0.95, width: width * widthScale, height: height * 0.04)
        prescriptionSlider.transform = CGAffineTransform(scaleX: 0.666, y: 0.666)
    }

    private func initLabel() {
        currentPrescriptionLabel.textAlignment = .center
        currentPrescriptionLabel.font = UIFont(name: "Avenir-Medium", size: 18)
        currentPrescriptionLabel.textColor = offwhiteColor
        currentPrescriptionLabel.attributedText = stringForPrescription(prescription: self.prescription)
        view.addSubview(currentPrescriptionLabel)
    }
    
    private func updateLabel() {
        let widthScale: CGFloat = 0.6
        currentPrescriptionLabel.frame = CGRect(x: CGFloat((1 - widthScale) / 2) * width, y: height * 0.91, width: width * widthScale, height: height * 0.03)
    }
    
    private func initButtons() {
        nextImageButton.setImage(UIImage(named: "picture")?.tint(with: offwhiteColor), for: .normal)
        nextImageButton.imageView?.contentMode = .scaleAspectFit
        nextImageButton.addTarget(self, action: #selector(nextImage), for: .touchUpInside)
        view.addSubview(nextImageButton)
        
        arButton.setImage(UIImage(named: "camera")?.tint(with: offwhiteColor), for: .normal)
        arButton.imageView?.contentMode = .scaleAspectFit
        arButton.addTarget(self, action: #selector(switchToAR), for: .touchUpInside)
        view.addSubview(arButton)
    }
    
    private func updateButtons() {
        let widthScale: CGFloat = 0.15
        nextImageButton.frame = CGRect(x: (0.125 - widthScale / 2) * width, y: 0.925 * height, width: width * widthScale, height: height * 0.05)
        arButton.frame = CGRect(x: (0.875 - widthScale / 2) * width, y: 0.925 * height, width: width * widthScale, height: height * 0.05)
    }
    
    @objc func switchToAR() {
        if (displayingAR) {
            cameraSession.stopRunning()
            displayImage(displayImages[currentImageIndex], prescription: prescription)
        } else {
            cameraSession = AVCaptureSession()
            cameraSession.sessionPreset = .low
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession)
            previewLayer.frame = self.imageView.bounds
            setupCameraSession()
            cameraSession.startRunning()
        }
        displayingAR = !displayingAR
//        previewView.frame = CGRect(x: 0, y: 0, width: width, height: height)
//        view.addSubview(previewView)
//        previewView.layer.zPosition = 10
    }
    
    @objc func nextImage() {
        currentImageIndex = (currentImageIndex + 1) % displayImages.count
        displayImage(displayImages[currentImageIndex], prescription: prescription)
    }
    
    @objc func updatePrescription(sender: UISlider) {
        prescription = Double(sender.value)
        self.currentPrescriptionLabel.attributedText = stringForPrescription(prescription: self.prescription)
        if displayingAR {
            return
        }
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.prescription == Double(sender.value) {
                self.displayImage(self.displayImages[self.currentImageIndex], prescription: self.prescription)
            }
        }
    }
    
    // camera view & etc
//    private func setupCameraSession() {
//        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
//            else {
//                return
//        }
//
//        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
//
//        cameraSession.beginConfiguration()
//        guard cameraSession.canAddInput(input) else {
//            return
//        }
//        cameraSession.addInput(input)
//        let output = AVCaptureVideoDataOutput()
//        // Drop frames if the computing lacks behind
//        output.alwaysDiscardsLateVideoFrames = true
//        let queue = DispatchQueue(label: "ac.video", attributes: [])
//
//        output.setSampleBufferDelegate(self, queue: queue)
//
//        guard cameraSession.canAddOutput(output) else {
//            return
//        }
//        cameraSession.addOutput(output)
//        output.connections.first?.videoOrientation = outputOrientation(for: UIScreen.main.orientation)
//
//        cameraSession.commitConfiguration()
//
//    }
    
    /// This method converts a UIDeviceOrientation to its according AVCaptureVideoOrientation.
    ///
    /// - Parameter orientation: The orientation of the device.
    /// - Returns: The orientation of the output.
    private func outputOrientation(for orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    func setupCameraSession() {
        guard let captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
//        captureDevice.activeVideoMaxFrameDuration = CMTime(seconds: Double(0.1), preferredTimescale: 1)
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)

            cameraSession.beginConfiguration()

            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }

            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true

            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
//            dataOutput.connections.first?.videoOrientation = outputOrientation(for: UIScreen.main.orientation)
            cameraSession.commitConfiguration()

            let queue = DispatchQueue(label: "ac.video", attributes: [])
            dataOutput.setSampleBufferDelegate(self, queue: queue)

        } catch let error {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("sample buffer not created")
            return
        }
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        guard let image: UIImage = convert(cmage: ciimage) else { return }
        DispatchQueue.main.async {
            self.displayImage(image, prescription: self.prescription)
        }
        
    }
}


/// Created attributed string for prescription label (highlight value)
///
/// - Parameter prescription: prescription
/// - Returns: the attributed string
func stringForPrescription(prescription: Double) -> NSAttributedString {
    let prescriptionValue = String(format: "%.1f", prescription)
    let baseAttrs: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.foregroundColor: offwhiteColor, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 16)! ]
    let attrString = NSMutableAttributedString(string: "prescription: " + prescriptionValue, attributes: baseAttrs)
    let range = NSRange(location: 0, length: 13)
    let lowerOpacity = [NSAttributedString.Key.foregroundColor: offwhiteColor.withAlphaComponent(0.7), NSAttributedString.Key.font: UIFont(name: "Avenir-Book", size: 16)!]
    attrString.addAttributes(lowerOpacity, range: range)
    return attrString
}

func convert(cmage: CIImage) -> UIImage? {
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(cmage, from: cmage.extent, format: CIFormat.RGBAh, colorSpace: nil) else { return nil }
    return UIImage(cgImage: cgImage)
}

let visionVC = VisionViewController()
PlaygroundPage.current.liveView = visionVC


