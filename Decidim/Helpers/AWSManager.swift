//
//  AWSManager.swift
//  Decidim
//
//  Created by Kyle Donnelly on 11/5/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import AWSCore
import AWSS3

class AWSManager {
    
    public static var shared = AWSManager()
    
    init() {
        precondition(self.configure())
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearCache), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc fileprivate func clearCache() {
        // Is there anything cached by AWSS3?
    }
    
}

extension AWSManager {
    
    fileprivate func configure() -> Bool {
        guard let plistPath = Bundle.main.path(forResource: "AWS-Info", ofType: "plist"),
              let plistContents = NSDictionary(contentsOfFile: plistPath) else {
          return false
        }
        
        guard let accessKey = plistContents.object(forKey: "ACCESS_KEY") as? String else {
            return false
        }
        guard let secretKey = plistContents.object(forKey: "SECRET_KEY") as? String else {
            return false
        }
        
        let creditialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: .USWest1, credentialsProvider: creditialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
//        let presignedEndpoint = AWSEndpoint(urlString: "https://kraken-api.herokuapp.com/s3/sign")
//        guard let presignedConfiguration = AWSServiceConfiguration(region: .USWest1, endpoint: presignedEndpoint, credentialsProvider: creditialsProvider) else {
//            return false
//        }
//        AWSS3PreSignedURLBuilder.register(with: presignedConfiguration, forKey: "USWest1S3PreSignedURLBuilder")
        
        return true
    }
    
}

extension AWSManager {
    
    // AWSS3 assumes bucket does not have dashes or underscores
    fileprivate static let Bucket = "votionapi"
    
    typealias ProgressBlock = (Progress) -> Void
    typealias LoadImageCompletionBlock = (UIImage?) -> Void
    typealias UploadImageCompletionBlock = (URL?) -> Void
    
    public func downloadImage(url: URL, progressBlock: ProgressBlock? = nil, completion: @escaping LoadImageCompletionBlock) -> AWSTask<AWSS3TransferUtilityDownloadTask> {
        let transferUtility = AWSS3TransferUtility.default()
        
        let downloadExpression = AWSS3TransferUtilityDownloadExpression()
        downloadExpression.progressBlock = { task, progress in
            progressBlock?(progress)
        }
        
        return transferUtility.downloadData(fromBucket: Self.Bucket, key: url.awsPath, expression: downloadExpression) { task, url, data, error in
            var image: UIImage? = nil
            defer {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
            guard error == nil else {
                return
            }
            guard url == nil else {
                return
            }
            guard let data = data else {
                return
            }
            
            image = UIImage(data: data)
        }
    }
    
    public func uploadImage(_ image: UIImage, path: URL, progressBlock: ProgressBlock? = nil, completion: @escaping UploadImageCompletionBlock) {
        let filename = path.lastPathComponent
        let imageType = path.pathExtension
        
        // to update, see https://stackoverflow.com/a/66254547
        var imageData: Data?
        var mimeType: String
        switch imageType {
        case "jpeg", "jpg":
            mimeType = "image/jpeg"
            imageData = image.jpegData(compressionQuality: 99.5)
        case "png":
            fallthrough // to default
        default:
            mimeType = "image/png"
            imageData = image.pngData()
        }
        
        guard let data = imageData else {
            completion(nil)
            return
        }
        
        self.uploadImage(data: data, mimeType: mimeType, filename: filename, progressBlock: progressBlock, completion: completion)
    }
    
    public func uploadImage(data: Data, mimeType: String, filename: String, progressBlock: ProgressBlock? = nil, completion: @escaping UploadImageCompletionBlock) {
        let transferUtility = AWSS3TransferUtility.default()
//        let urlBuilder = AWSS3PreSignedURLBuilder.s3PreSignedURLBuilder(forKey: "USWest1S3PreSignedURLBuilder")
//        let urlRequest = AWSS3GetPreSignedURLRequest()
//        urlRequest.bucket = "votionapi"
//        urlRequest.key = "user_uploads"
//        urlRequest.httpMethod = .PUT
//        urlRequest.expires = .distantFuture
//        urlRequest.contentType = "image/png"
//
//        urlBuilder.getPreSignedURL(urlRequest).continueWith {
//            if let e = $0.error {
//                print(e)
//            } else if let url = $0.result {
//                print(url)
//            }
//            return nil
//        }
        
        let key = "user_uploads/\(filename)"
        
        let uploadCompletion: (AWSS3TransferUtilityTask, Error?) -> Void = { task, error in
            var url: URL? = nil
            defer {
                DispatchQueue.main.async {
                    completion(url)
                }
            }
            guard error == nil else { return }
            guard let responseURL = task.response?.url else { return }
            guard var components = URLComponents(url: responseURL, resolvingAgainstBaseURL: false) else { return }
            
            components.query = nil
            components.fragment = nil
            url = components.url
        }
        
        if data.count >= 5 * 1024 * 1024 {
            transferUtility.uploadUsingMultiPart(data: data,
                                                 bucket: Self.Bucket,
                                                 key: key,
                                                 contentType: mimeType,
                                                 expression: nil) { (task, error) in
                uploadCompletion(task, error)
            }.continueWith {
                guard $0.error == nil else { return nil }
                guard let uploadTask = $0.result else { return nil }
                
                uploadTask.setProgressBlock { task, progress in
                    progressBlock?(uploadTask.progress)
                }
                return nil
            }
        } else {
            let transferExpression = AWSS3TransferUtilityUploadExpression()
            transferExpression.setValue("public-read", forRequestParameter: "x-amz-acl")
            transferExpression.setValue("public-read", forRequestHeader: "x-amz-acl")
            transferExpression.progressBlock = { task, progress in
                progressBlock?(progress)
            }
            
            transferUtility.uploadData(data,
                                       bucket: Self.Bucket,
                                       key: key,
                                       contentType: mimeType,
                                       expression: nil) { (task, error) in
                uploadCompletion(task, error)
            }
        }
    }
    
}

extension URL {
    
    public init?(awsString: String) {
        guard let url = URL(string: awsString) else { return nil }
        guard let host = url.host, host.hasPrefix(AWSManager.Bucket) else { return nil }
        self = url
    }
    
    fileprivate var awsPath: String {
        if self.path.hasPrefix("/") {
            var path = self.path
            path.remove(at: path.startIndex)
            return path
        } else {
            return self.path
        }
    }
    
}
