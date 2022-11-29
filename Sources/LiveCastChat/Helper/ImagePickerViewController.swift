//
//  ImagePickerViewController.swift
//  LiveCast
//
//  Created by Игорь on 12.0122..
//

import UIKit
import AVFoundation

public enum PickerMediaType: String {
    case photo = "public.image"
    case video = "public.movie"
}
                            
public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
    func didSelectVideo(with url: URL?)
}

open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    var exportSession: AVAssetExportSession!

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate, mediaTypes: [PickerMediaType] = [.photo, .video], allowsEditing: Bool = false) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = allowsEditing
        self.pickerController.mediaTypes = mediaTypes.map({ $0.rawValue })
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }
    
    public func presentCamera() {
        self.pickerController.sourceType = .camera
        self.presentationController?.present(self.pickerController, animated: true)
    }
    
    public func presentGallery() {
        self.pickerController.sourceType = .photoLibrary
        self.presentationController?.present(self.pickerController, animated: true)
    }


    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.pickerController(picker, didSelect: image)
            return
        }
        
        if let image = info[.originalImage] as? UIImage {
            self.pickerController(picker, didSelect: image)
            return
        }
        
        if let videoUrl = info[.mediaURL] as? URL {
            encodeVideo(videoUrl)
            pickerController.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    func encodeVideo(_ videoURL: URL)  {
            let avAsset = AVURLAsset(url: videoURL, options: nil)
            
            //Create Export session
            exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let filePath = documentsDirectory.appendingPathComponent("rendered-Video.mp4")
            deleteFile(filePath)
            
            exportSession!.outputURL = filePath
            exportSession!.outputFileType = AVFileType.mp4
            exportSession!.shouldOptimizeForNetworkUse = true
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
            exportSession.timeRange = range
            
            exportSession!.exportAsynchronously(completionHandler: {() -> Void in
                DispatchQueue.main.async {
                    
                    switch self.exportSession!.status {
                    case .failed:
                        return
                    case .cancelled:
                        return
                    case .completed:
                        if let url = self.exportSession.outputURL {
                            //Rendered Video URL
                            self.delegate?.didSelectVideo(with: url)

                        }
                    default:
                        break
                    }
                }
            })
        }
    
    func deleteFile(_ filePath: URL) {
            guard FileManager.default.fileExists(atPath: filePath.path) else {
                return
            }
            
            do {
                try FileManager.default.removeItem(atPath: filePath.path)
            } catch {
                fatalError("Unable to delete file: \(error) : \(#function).")
            }
        }
}

extension ImagePicker: UINavigationControllerDelegate {
}
