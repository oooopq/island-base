//
//  SystemSettings.swift
//  Island Base
//
//  権限を拒否したあと、このアプリの設定画面を開く
//

import UIKit

enum SystemSettings {
    static func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
