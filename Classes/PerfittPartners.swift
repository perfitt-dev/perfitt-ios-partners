//
//  PerfittPartners.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/04.
//


import UIKit
import AVFoundation

open class PerfittPartners: UIImageView, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // 카메라 관련 컴포넌트
    private var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!             // 사용될 카메라
    private var stillImageOutput: AVCapturePhotoOutput!             // 이미지를 캡쳐 데이터
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!      // 카메라 화면과 연결
    private lazy var videoDataOutput = AVCaptureVideoDataOutput()   // 카메라 화면을 매 프레임마다 체크하기
    // 카메라 컨트롤
    let sessionQueue = DispatchQueue(label: "session-queue")
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.configCameraAndStartSession()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // 카메라 권한 확인및 설정
    func configCameraAndStartSession() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        // 카메라 권한이 true인 경우
        case .authorized, .notDetermined:
            self.setupSession()
            self.startSession()
        // 카메라 권한을 설정하지 않은경우
        case .denied:
            BaseController.showAlertTwoBtn(title: "알림", message: "사진 촬영을 할 수 있도록 허용하시겠습니까?", handler: { _ in
                guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }, cancelHandler: nil)

        case .restricted:
            BaseController.showAlert(title: "알림", message: "카메라를 사용할 수 없습니다.", handler: nil)
        default:
            debugPrint("status failed")
            break
        }
    }
    
    func setupSession() {
        self.session = AVCaptureSession()
        self.session.sessionPreset = .high          // photo 해상도 결정
        self.session.beginConfiguration()           // session 구성 시작
        
        // Add Video Input
        do {
            var defaultCamera: AVCaptureDevice?    // 핸드폰의 카메라를 찾기위해 사용하는 변수
            
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
//            let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
//            videoDataOutput = AVCaptureVideoDataOutput()
            
//            videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
//            videoDataOutput.alwaysDiscardsLateVideoFrames = true
//            videoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
            
            // 화면의 이미지를 한순간 가져올 컴포넌트 정의
            stillImageOutput = AVCapturePhotoOutput()
            stillImageOutput.isHighResolutionCaptureEnabled = true

            // 세션에 들어갈수 있는지 확인
            if self.session.canAddInput(videoDeviceInput) && session.canAddOutput(videoDataOutput) && self.session.canAddOutput(stillImageOutput) {
                session.addInput(videoDeviceInput)
                session.addOutput(videoDataOutput)
                session.addOutput(stillImageOutput)
                videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
                self.setupCamera()
            }
            else {
                // 세션 구성 종료
                self.session.commitConfiguration()
            }
            
        } catch {
            // 세션 구성 종료
            self.session.commitConfiguration()
        }
        // 세션 구성 종료
        self.session.commitConfiguration()
        
        // 기본 배율 설정
//        self.updateCameraScale(scale: self.lastZoomFactor)
    }
    
    // 세션 시작
    func startSession() {
        if !self.session.isRunning {
            sessionQueue.async {
                self.session.startRunning()
            }
            
        }
    }
    
    private func setupCamera() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoPreviewLayer.frame = self.frame
        self.layer.addSublayer(videoPreviewLayer)
    }
    
    
}
