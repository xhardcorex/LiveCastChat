//
//  CustomError.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 13.03.2022.
//

import Foundation

class CustomError: NSError {
    var title: String?
    var errorDescription: String
    var errorCode: Int
    
    override var code: Int {
        return errorCode
    }
    
    override var description: String {
        return errorDescription
    }

    override var localizedDescription: String {
        return errorDescription
    }
    
    init(title: String? = nil, description: String, code: Int? = nil) {
        self.title = title ?? "Error"
        self.errorDescription = description
        let defaultCode = -1
        self.errorCode = code ?? defaultCode
        super.init(domain: "", code: code ?? defaultCode, userInfo: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
