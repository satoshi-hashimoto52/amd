//
//  VideoCapture.swift
//  amd
//
//  Created by 橋本諭 on 2024/07/10.
//

import Foundation
import AVFoundation
import opencv2

class VideoCapture: NSObject {
    let captureSession = AVCaptureSession()
    var handler: ((CMSampleBuffer) -> Void)?

    override init() {
        super.init()
        setup()
    }

    func setup() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        do {
            try device?.lockForConfiguration()
            device?.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            device?.focusMode = .continuousAutoFocus
            device?.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
            device?.exposureMode = .continuousAutoExposure
            device?.whiteBalanceMode = .continuousAutoWhiteBalance
            device?.unlockForConfiguration()
        } catch {
            print("Error locking configuration: \(error)")
        }

        guard
            let deviceInput = try? AVCaptureDeviceInput(device: device!),
            captureSession.canAddInput(deviceInput)
        else { return }
        captureSession.addInput(deviceInput)

        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "mydispatchqueue"))
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        guard captureSession.canAddOutput(videoDataOutput) else { return }
        captureSession.addOutput(videoDataOutput)

        for connection in videoDataOutput.connections {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }

        captureSession.commitConfiguration()
    }

    func run(_ handler: @escaping (CMSampleBuffer) -> Void) {
        if !captureSession.isRunning {
            self.handler = handler
            captureSession.startRunning()
        }
    }

    func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        handler?(sampleBuffer)
    }
}
