//
//  SafariView.swift
//  antiuv
//
//  Created by AntiUV Team on 2026/3/11.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.preferredControlTintColor = .orange
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
