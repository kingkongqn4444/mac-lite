import SwiftUI
import AVFoundation

struct CameraView: View {
    let windowState: WindowState
    @State private var authorized = false

    var body: some View {
        VStack(spacing: 0) {
            if authorized {
                CameraPreview()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)

                // Controls
                HStack(spacing: 20) {
                    Spacer()
                    Button { } label: {
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 40, height: 40)
                            .overlay(Circle().fill(.white).frame(width: 32, height: 32))
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(.black)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("Camera Access Required")
                        .font(.system(size: 13, weight: .medium))
                    Button("Allow Access") { requestAccess() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
            }
        }
        .onAppear {
            windowState.title = "FaceTime"
            requestAccess()
        }
    }

    private func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { authorized = granted }
        }
    }
}

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let session = AVCaptureSession()
        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return view }

        if session.canAddInput(input) { session.addInput(input) }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        context.coordinator.previewLayer = previewLayer
        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }

        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = view.bounds
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
