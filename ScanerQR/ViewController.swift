import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet private weak var viewCamera: UIView!
    
    private var avCaptureSession = AVCaptureSession()
    private var preview = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAccessCamera()
    }
    
    private func requestAccessCamera() {
        AVCaptureDevice.requestAccess(for: .video) { succes in
            if succes {
                self.initVideo()
            } else {
                //pedir que lo active en configuraciones
            }
        }
    }
    
    private func initVideo() {
        DispatchQueue.global(qos: .background).async {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
                  self.avCaptureSession.canAddInput(videoInput) else {
                return
            }
            self.avCaptureSession.addInput(videoInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            guard self.avCaptureSession.canAddOutput(metadataOutput) else {
                return
            }
            self.avCaptureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417, .upce, .code128, .code39, .code39Mod43, .code93, .interleaved2of5, .itf14, .upce]
            
            self.preview = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
            DispatchQueue.main.async {
                self.preview.frame = self.viewCamera.layer.bounds
                self.preview.videoGravity = .resize
                self.viewCamera.layer.addSublayer(self.preview)
            }
            self.avCaptureSession.startRunning()
        }
    }

}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first {
            guard let objeto = first as? AVMetadataMachineReadableCodeObject,
                  let strValue = objeto.stringValue else {
                return
            }
            let alerta = UIAlertController(title: "Texto QR o Barras", message: strValue, preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alerta, animated: true)
        } else {
            print("No se pudo leer el codigo")
        }
    }
    
}
