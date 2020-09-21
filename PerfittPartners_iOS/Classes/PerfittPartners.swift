////
////  PerfittPartners.swift
////  PerfittPartners_iOS
////
////  Created by nick on 2020/09/04.
////
//
//
//import UIKit
//import AVFoundation
//
//
//@objc open class PerfittPartners:  {
//    // 카메라 관련 컴포넌트
//    private var session = AVCaptureSession()
//    private var videoDeviceInput: AVCaptureDeviceInput!             // 사용될 카메라
//    private var stillImageOutput: AVCapturePhotoOutput!             // 이미지를 캡쳐 데이터
//    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!      // 카메라 화면과 연결
//    private lazy var videoDataOutput = AVCaptureVideoDataOutput()   // 카메라 화면을 매 프레임마다 체크하기
//    // 카메라 컨트롤
//    let sessionQueue = DispatchQueue(label: "session-queue")
//
//    // 카메라 뷰 레이어
//    private var previewLayer: UIImageView = UIImageView()
//    private var motionView: Motion!
//
//    var rightImg: Bool?
//    var rightImgData: String?
//    var leftImgData: String?
//
//    var APIKEY: String?
//
//    public struct PerfittPartnersModel: Codable {
//        var callBackName: String!
//    }
//
//    @objc public convenience init(APIKey: String) {
//        self.init()
//        self.APIKEY = APIKey
//    }
//
//    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    public required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if !UserDefaults.standard.bool(forKey: "isPerfittTutorial") {
//            UserDefaults.standard.setValue(true, forKey: "isPerfittTutorial")
//
//        }
//
//        let rightBtn = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(pushTutorial))
//        self.navigationItem.rightBarButtonItem = rightBtn
//
//        let titleStr = rightImg == nil ? "Right" : "Left"
//        self.title = titleStr == "Right" ? "오른발 촬영하기" : "왼발 촬영하기"
//        self.setBaseLayout()
//        self.configCameraAndStartSession()
//    }
//
//    @objc func pushTutorial() {
//        self.navigationController?.pushViewController(PerfittTutorialVC(), animated: true)
//    }
//
//    private func setBaseLayout() {
//        self.view.backgroundColor = .black
//        self.motionView = Motion()
//        self.motionView.delegate = self
//        self.view.addSubview(previewLayer)
//        self.view.addSubview(motionView)
//        self.previewLayer.translatesAutoresizingMaskIntoConstraints = false
//        self.motionView.translatesAutoresizingMaskIntoConstraints = false
//
//        self.previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 96)
//        NSLayoutConstraint.activate([
//            self.previewLayer.topAnchor.constraint(equalTo: self.view.topAnchor),
//            self.previewLayer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.previewLayer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//
//            self.motionView.topAnchor.constraint(equalTo: self.previewLayer.bottomAnchor),
//            self.motionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            self.motionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            self.motionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            self.motionView.heightAnchor.constraint(equalToConstant: 96)
//        ])
//    }
//
//    // 카메라 권한 확인및 설정
//    private func configCameraAndStartSession() {
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//        switch status {
//        // 카메라 권한이 true인 경우
//        case .authorized, .notDetermined:
//            self.setupSession()
//            self.startSession()
//        // 카메라 권한을 설정하지 않은경우
//        case .denied:
//
//            self.showAlertTwoBtn(title: "알림", message: "사진 촬영을 할 수 있도록 허용하시겠습니까?", handler: { _ in
//                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
//                UIApplication.shared.open(url)
//            }, cancelHandler: nil)
//
//        case .restricted:
//            self.showAlert(title: "알림", message: "카메라를 사용할 수 없습니다.", handler: nil)
//        default:
//            debugPrint("status failed")
//            break
//        }
//    }
//
//    private func setupSession() {
//        self.session = AVCaptureSession()
//        self.session.sessionPreset = .hd1280x720          // photo 해상도 결정
//        self.session.beginConfiguration()           // session 구성 시작
//
//        // Add Video Input
//        do {
//            var defaultCamera: AVCaptureDevice?    // 핸드폰의 카메라를 찾기위해 사용하는 변수
//
//            if let backCamera = AVCaptureDevice.default(for: .video) {
//                defaultCamera = backCamera
//            }
//
//            guard let camera = defaultCamera else {
//                // 핸드폰에서 카메라를 사용할수 없을때
//                self.session.commitConfiguration()
//                debugPrint("camera load failed")
//                return
//            }
//            // 화면의 정보를 가져올 장치를 정의
//            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
//
//            // 화면의 정보를 매프레임마다 업데이트하는 컴포넌트 정의
//            let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
//            videoDataOutput = AVCaptureVideoDataOutput()
//
//            videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
//            videoDataOutput.alwaysDiscardsLateVideoFrames = true
//            videoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
//
//            // 화면의 이미지를 한순간 가져올 컴포넌트 정의
//            stillImageOutput = AVCapturePhotoOutput()
//            stillImageOutput.isHighResolutionCaptureEnabled = true
//
//            // 세션에 들어갈수 있는지 확인
//            if self.session.canAddInput(videoDeviceInput) && session.canAddOutput(videoDataOutput) && self.session.canAddOutput(stillImageOutput) {
//                session.addInput(videoDeviceInput)
//                session.addOutput(videoDataOutput)
//                session.addOutput(stillImageOutput)
//                videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
//                self.setupCamera()
//            }
//            else {
//                // 세션 구성 종료
//                self.session.commitConfiguration()
//            }
//
//        } catch {
//            // 세션 구성 종료
//            self.session.commitConfiguration()
//        }
//        // 세션 구성 종료
//        self.session.commitConfiguration()
//
//        // 기본 배율 설정
////        self.updateCameraScale(scale: self.lastZoomFactor)
//    }
//
//    // 세션 시작
//    private func startSession() {
//        if !self.session.isRunning {
//            sessionQueue.async {
//                self.session.startRunning()
//            }
//        }
//    }
//
//    // 카메라 설정
//    private func setupCamera() {
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
//        videoPreviewLayer.videoGravity = .resizeAspectFill
//        videoPreviewLayer.connection?.videoOrientation = .portrait
////        videoPreviewLayer.frame = self.view.frame
//        videoPreviewLayer.frame = self.previewLayer.frame
//        self.previewLayer.layer.addSublayer(videoPreviewLayer)
////        self.layer.addSublayer(videoPreviewLayer)
//    }
//
//    private func showAlert(title: String, message: String, handler: ((UIAlertAction) -> ())?) {
//        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
//        controller.addAction(okAction)
//        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
//    }
//
//    func showAlertTwoBtn(title: String, message: String, handler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
//        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
//        let cancelAction = UIAlertAction(title: "취소", style: .default, handler: cancelHandler)
//        controller.addAction(cancelAction)
//        controller.addAction(okAction)
//        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)    }
//}
//
//
//extension PerfittPartners: AVCaptureVideoDataOutputSampleBufferDelegate { }
//
//
//// 자이로센서를 사용해서 수평을 맞춥니다.
//extension PerfittPartners: MotionDelegate {
//    public func setCurrentStatus(status: Bool) {
//
//    }
//
//    // 셔터 클릭
//    public func tapButton() {
//        debugPrint("testasetastase")
//        // 저장될 화면을 셋팅
//        var photoSettings: AVCapturePhotoSettings
//        photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
//        photoSettings.isAutoStillImageStabilizationEnabled = true
//
//        // 화면을 저장합니다.
//        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
//    }
//}
//
//extension PerfittPartners: AVCapturePhotoCaptureDelegate {
//    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard error == nil else {
//            print("Fail to capture photo: \(String(describing: error))")
//            return
//        }
//
//        guard let imageData = photo.fileDataRepresentation() else {
//            print("Fail to convert pixel buffer")
//            return
//        }
//
//        let previewVC = PreviewVC()
//        previewVC.imageData = imageData
//        previewVC.previewFor = "Right"
//        previewVC.APIKEY = self.APIKEY
//
//        if let _ = rightImg {
//            previewVC.rightImgData = self.rightImgData
//            previewVC.previewFor = "Left"
//        }
//        self.navigationController?.pushViewController(previewVC, animated: true)
//    }
//}

import UIKit

open class PerfittPartners: UIView {
    private var contentView: UIView!
    private var titleLabel: UILabel!
    private var lineView: UIView!
    private var confirmButton: UIButton!

    private var titleText: String?
    private var confirmText: String?
    private var completion: (() -> Void)?

    public convenience init(title: String, confirm: String, completion: (() -> Void)?) {
        self.init(frame: CGRect.zero)

        self.titleText = title
        self.confirmText = confirm
        self.completion = completion
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        contentView = UIView()
        titleLabel = UILabel()
        lineView = UIView()
        confirmButton = UIButton(type: .custom)

        self.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setAttribute() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)

        contentView.layer.cornerRadius = 14.0
        contentView.backgroundColor = .white

        lineView.backgroundColor = .lightGray

        titleLabel.text = titleText ?? "Title"

        confirmButton.setTitle(confirmText ?? "confirm", for: .normal)
        confirmButton.setTitleColor(.blue, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    open func show(in superview: UIView) {
        setAttribute()

        superview.addSubview(self)
        self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true

        self.addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 270.0).isActive = true

        contentView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50.0).isActive = true

        contentView.addSubview(lineView)
        lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        contentView.addSubview(confirmButton)
        confirmButton.topAnchor.constraint(equalTo: lineView.bottomAnchor).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
    }

    @objc
    private func confirmAction() {
        self.removeFromSuperview()
        completion?()
    }
}
