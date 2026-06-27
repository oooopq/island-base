//
//  LiveCamera.swift
//  Island Now
//
//  ライブカメラ1件分の情報
//

import Foundation

struct LiveCamera: Identifiable, Hashable {
    var id: String { urlString }
    let title: String
    let urlString: String

    var linkURL: URL? {
        AppURL.from(string: urlString)
    }
}
