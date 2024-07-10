//
//  ContentView.swift
//  amd
//
//  Created by 橋本諭 on 2024/07/09.
//

import SwiftUI
import UIKit
import AVFoundation
import opencv2

enum ImageProcessor {
    static func grayscale(image: UIImage?) -> UIImage? {
        guard let image = image else {
            return nil
        }

        let mat = Mat(uiImage: image)
        Imgproc.cvtColor(src: mat, dst: mat, code: ColorConversionCodes.COLOR_RGB2GRAY)
        return mat.toUIImage()
    }
}

struct ContentView: View {
    let videoCapture = VideoCapture()
    @State private var image: UIImage? = UIImage(named: "placeholder")  // 初期プレースホルダー画像

    var body: some View {
        VStack {
            // カメラの映像を表示
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 480)
            }

            HStack {
                Button("Start Capture") {
                    startCapturing()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Stop Capture") {
                    videoCapture.stop()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }

    func startCapturing() {
        videoCapture.run { sampleBuffer in
            // CMSampleBufferからUIImageを作成
            guard let uiImage = self.convertSampleBufferToUIImage(sampleBuffer) else {
                return
            }
            DispatchQueue.main.async {
                // ここで映像をグレースケールに変換
                self.image = ImageProcessor.grayscale(image: uiImage)
            }
        }
    }

    private func convertSampleBufferToUIImage(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
