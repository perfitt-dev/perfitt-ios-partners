//
//  PerfittCameraVC.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/10/27.
//

import UIKit
import AVFoundation

public class PerfittCameraVC: UIViewController {
    
    // 카메라 관련 컴포넌트
    private var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!             // 사용될 카메라
    private var stillImageOutput: AVCapturePhotoOutput!             // 이미지를 캡쳐 데이터
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!      // 카메라 화면과 연결
    private var videoDataOutput: AVCaptureVideoDataOutput!          // 카메라 화면을 매 프레임마다 체크하기
    // 카메라 컨트롤
    let sessionQueue = DispatchQueue(label: "session-queue")
    
    // storyboard와 연결된 컴포넌트
    @IBOutlet weak var previewLayer: UIImageView!
    @IBOutlet weak var motionView: Motion!
    @IBOutlet weak var overlayView: OverlayView!
    // 카메라 줌인, 줌아웃 버튼
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    
    // 카메라 줌 인 아웃 범위, 기본값
    private let minimumZoom: CGFloat = 1.4
    private let maximumZoom: CGFloat = 2.2
    private var lastZoomFactor: CGFloat = 1.8
    
    // 분기 혹은 데이터 저장용 변수
    var rightImg: Bool?
    var rightImgData: String?
    var leftImgData: String?
    
    // 사용자 가이드라인
    var guideLine: UIView = UIView()
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var baseDectetionLable: UILabel!
    @IBOutlet weak var footDectionLabel: UILabel!
    
    // 가이드라인과 맞다아있는지 확인하는 변수
    var maxY: CGFloat = 0.0
    var minY: CGFloat = 0.0
    
    // tensorflow lite model handler init
    private var modelDataHandler: ModelDataHandler? = ModelDataHandler(modelFileInfo: MobileNetSSD.modelInfo, labelsFileInfo: MobileNetSSD.labelsInfo)
    // run model
    private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000
    private let delayBetweenInferencesMs: Double = 200
    // tensorflow lite model result
    private var result: Result?
    // overlay rectangle 위치, 라벨 폰트
    private let edgeOffset: CGFloat = 2.0
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        motionView.delegate = self
        if let isRight = self.rightImg, isRight {
            self.title = "오른발 촬영하기"
        }
        else {
            self.title = "왼발 촬영하기"
        }

//        self.title = self.rightImg ?? true ? "오른발 촬영하기" : "왼발 촬영하기"
        self.setButtonLayout()
    }
    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // carmera start
//        self.configCameraAndStartSession()
//    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // carmera start
        self.configCameraAndStartSession()
        modelDataHandler?.delegate = self
        
    }
    
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 카메라 종료
        if self.session.isRunning {
            self.cleanupCamera()
        }
    }
    
    private func setButtonLayout() {
        self.zoomInButton.layer.cornerRadius = 8
        self.zoomInButton.layer.borderWidth = 1
        self.zoomInButton.layer.borderColor = UIColor.white.cgColor
        self.zoomInButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        self.zoomOutButton.layer.cornerRadius = 8
        self.zoomOutButton.layer.borderWidth = 1
        self.zoomOutButton.layer.borderColor = UIColor.white.cgColor
        self.zoomOutButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
}

//  카메라 관련 설정
extension PerfittCameraVC {
    // 카메라 권한 확인및 설정
    private func configCameraAndStartSession() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        // 카메라 권한이 true인 경우
        case .authorized, .notDetermined:
            
            self.setupSession()
            self.startSession()
            
        // 카메라 권한을 설정하지 않은경우
        case .denied:
            self.showAlertTwoBtn(title: "알림", message: "사진 촬영을 할 수 있도록 허용하시겠습니까?", handler: { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }, cancelHandler: nil)
            
        case .restricted:
            self.showAlert(title: "알림", message: "카메라를 사용할 수 없습니다.", handler: nil)
        default:
            debugPrint("status failed")
            break
        }
    }
    
    // 카메라 속성 설정
    private func setupSession() {
        self.session = AVCaptureSession()
//        self.session.sessionPreset = .hd1280x720                // photo 해상도 결정
        self.session.sessionPreset = .high
        self.session.beginConfiguration()                       // session 구성 시작
        
        // Add Video Input
        do {
            var defaultCamera: AVCaptureDevice?                 // 핸드폰의 카메라를 찾기위해 사용하는 변수
            
            if let backCamera = AVCaptureDevice.default(for: .video) {
                defaultCamera = backCamera
            }
            
            guard let camera = defaultCamera else {
                // 핸드폰에서 카메라를 사용할수 없을때
                self.session.commitConfiguration()
                debugPrint("camera load failed")
                return
            }
            // 화면의 정보를 가져올 장치를 정의
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            
            // 화면의 정보를 매프레임마다 업데이트하는 컴포넌트 정의
            let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
            
            // 화면의 이미지를 한순간 가져올 컴포넌트 정의
            stillImageOutput = AVCapturePhotoOutput()
            stillImageOutput.isHighResolutionCaptureEnabled = true
            
            // 세션에 들어갈수 있는지 확인
            if self.session.canAddInput(videoDeviceInput) && session.canAddOutput(videoDataOutput) && self.session.canAddOutput(stillImageOutput) {
                session.addInput(videoDeviceInput)
                session.addOutput(videoDataOutput)
                session.addOutput(stillImageOutput)
                videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
                debugPrint("in session success")
                self.setupCamera()
            }
            else {
                // 세션 구성 종료
                debugPrint("in session failed")
                self.session.commitConfiguration()
            }
            
        } catch {
            // 세션 구성 종료
            self.session.commitConfiguration()
        }
        // 세션 구성 종료
        self.session.commitConfiguration()
        
        // 기본 배율 설정
        self.updateCameraScale(scale: self.lastZoomFactor)
    }
    
    // 카메라 동작 시작
    private func startSession() {
        if !self.session.isRunning {
            sessionQueue.async {
                self.session.startRunning()
            }
        }
    }
    
    // 세션 종료
    func stopSession() {
        if self.session.isRunning {
            sessionQueue.async {
                self.session.stopRunning()
            }
        }
    }
    
    // 카메라 화면 레이어 삭제
    func cleanupCamera() {
        self.stopSession()
        guard videoPreviewLayer != nil else {
            debugPrint("videoPreviewLayer nil")
            return;
        }
        videoPreviewLayer.removeFromSuperlayer()
    }
    
    private func setupCamera() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.frame = self.previewLayer.bounds
        self.previewLayer.layer.addSublayer(videoPreviewLayer)
        self.previewLayer.layer.layoutIfNeeded()
        
        self.setGuideLine()
    }
    
    private func setGuideLine() {
        self.guideLine.backgroundColor = .red
        self.guideLine.translatesAutoresizingMaskIntoConstraints = false
        
        self.overlayView.addSubview(guideLine)
        let guideLineYPos = self.overlayView.bounds.size.height * 0.3
        let baseRange = self.overlayView.bounds.size.height * 0.01
        
        self.minY = guideLineYPos - baseRange
        self.maxY = guideLineYPos + baseRange
        
        NSLayoutConstraint.activate([
            self.guideLine.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.guideLine.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.guideLine.heightAnchor.constraint(equalToConstant: 2),
            self.guideLine.topAnchor.constraint(equalTo: self.overlayView.topAnchor, constant: guideLineYPos)
        ])
    }
}

// 자이로센서를 사용해서 수평을 맞춥니다.
extension PerfittCameraVC: MotionDelegate {
    public func setCurrentStatus(status: Bool) {
        
        DispatchQueue.main.async {
            if status {
                self.balanceLabel.isHidden = true
            }
            else {
                self.balanceLabel.isHidden = false
            }
        }
        
    }
    
    // 셔터 클릭
    public func tapButton() {
        // 저장될 화면을 셋팅
        var photoSettings: AVCapturePhotoSettings
        photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isAutoStillImageStabilizationEnabled = true
        
        // 화면을 저장합니다.
//        if self.baseDectetionLable.isHidden && self.footDectionLabel.isHidden {
//            stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
//        }
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
}

extension PerfittCameraVC: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Fail to convert pixel buffer")
            return
        }

        
        let bundles = Bundle.main.loadNibNamed("CaptureVC", owner: self, options: nil)
        let captureVC = bundles?.filter({ $0 is CaptureVC }).first as? CaptureVC
        
        
        
        captureVC?.imageData = imageData
        captureVC?.previewFor = "Right"
        
        if let isRight = rightImg, !isRight {
            captureVC?.rightImgData = self.rightImgData
            captureVC?.previewFor = "Left"
        }
        
        self.navigationController?.pushViewController(captureVC ?? self, animated: true)
    }
}

extension PerfittCameraVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    /** This method delegates the CVPixelBuffer of the frame seen by the camera currently.
     */
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // CMSampleBuffer를 CVPixelBuffer로 변환
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard let imagePixelBuffer = pixelBuffer else {
            return
        }
        

        self.runModel(onPixelBuffer: imagePixelBuffer)
    }
    
    // TFL 모델을 실행
    @objc  func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        guard  (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else { return }
        previousInferenceTimeMs = currentTimeMs
        result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)
        guard let displayResult = result else { return }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // overlayView에 라벨과 텍스트를 업데이트합니다.
        DispatchQueue.main.async {
            self.drawAfterPerformingCalculations(onInferences: displayResult.inferences, withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
        }
        
    }
    
    func drawAfterPerformingCalculations(onInferences inferences: [Inference], withImageSize imageSize:CGSize) {
        self.overlayView.objectOverlays = []
        self.overlayView.setNeedsDisplay()
        
        guard !inferences.isEmpty else { return }
        
        var objectOverlays: [ObjectOverlay] = []
        
        for inference in inferences {
            // Translates bounding box rect to current view.
            
            
            var convertedRect = inference.rect.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / imageSize.width, y: self.overlayView.bounds.size.height / imageSize.height))
            debugPrint("tf model rect : \(inference.rect)\nconverted rect : \(convertedRect)" )
            if convertedRect.origin.x < 0 {
                convertedRect.origin.x = self.edgeOffset
            }
            if convertedRect.origin.y < 0 {
                convertedRect.origin.y = self.edgeOffset
            }
            
            if convertedRect.maxY > self.overlayView.bounds.maxY {
                convertedRect.size.height = self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
            }
            if convertedRect.maxX > self.overlayView.bounds.maxX {
                convertedRect.size.width = self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
            }
            
            let confidenceValue = Int(inference.confidence * 100.0)
            let string = "\(inference.className)  (\(confidenceValue)%)"
            
            //            let size = string.size(usingFont: self.displayFont)
            let size = CGSize(width: 100, height: 20)
            let objectOverlay = ObjectOverlay(name: string, borderRect: convertedRect, nameStringSize: size, color: inference.displayColor, font: self.displayFont)
    
            objectOverlays.append(objectOverlay)
            debugPrint("rect: ", convertedRect)
        }
        
        // Hands off drawing to the OverlayView
        self.draw(objectOverlays: objectOverlays)
    }
    
    /** Calls methods to update overlay view with detected bounding boxes and class names.
     */
    func draw(objectOverlays: [ObjectOverlay]) {
        
        self.overlayView.objectOverlays = objectOverlays
        self.overlayView.setNeedsDisplay()
    }
}

extension PerfittCameraVC: ModelDataHandlerDelegate {
    func detectedFoot(status: Bool) {
        DispatchQueue.main.async {
            if status {
                self.footDectionLabel.isHidden = true
            }
            else {
                self.footDectionLabel.isHidden = false
            }
            
        }
        
    }
    
    func detectedBase(rect: CGRect, imgSize: CGSize) {
        
        DispatchQueue.main.async {
            let targetRect = rect.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / imgSize.width, y: self.overlayView.bounds.size.height / imgSize.height))
            
            if (self.minY...self.maxY).contains(targetRect.origin.y) {
                self.baseDectetionLable.isHidden = true
            }
            else {
                self.baseDectetionLable.isHidden = false
            }
        }
    }
}

// camera action
extension PerfittCameraVC {
    
    // 화면 이미지 축소 ( - )
    @IBAction func onZoomOut(_ sender: UIButton) {
        // 화면 스케일값 업데이트 및 적용
        self.lastZoomFactor = self.minMaxZoom(self.lastZoomFactor - 0.4)
        self.updateCameraScale(scale: self.lastZoomFactor)
    }
    
    // 화면 이미지 확대 ( + )
    @IBAction func onZoomIn(_ sender: UIButton) {
        // 화면 스케일값 업데이트 및 적용
        self.lastZoomFactor = self.minMaxZoom(self.lastZoomFactor + 0.4)
        self.updateCameraScale(scale: self.lastZoomFactor)
    }
    
    // zoom의 범위 확인
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return 0
        }
        
        return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
    }
    
    // 화면 스케일 업데이트
    func updateCameraScale(scale factor: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            defer {
                device.unlockForConfiguration()
            }
            device.videoZoomFactor = factor
        } catch {
            print("\(error.localizedDescription)")
            
        }
    }
}

extension PerfittCameraVC {
    private func showAlert(title: String, message: String, handler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    func showAlertTwoBtn(title: String, message: String, handler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: cancelHandler)
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
}



