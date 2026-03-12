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
    
    func makeUIViewController(context: Context) -> CustomSafariViewController {
        return CustomSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: CustomSafariViewController, context: Context) {}
}

class CustomSafariViewController: UIViewController {
    private var safariViewController: SFSafariViewController?
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        configuration.barCollapsingEnabled = false
        
        let safariVC = SFSafariViewController(url: url, configuration: configuration)
        safariVC.preferredControlTintColor = .orange
        safariVC.delegate = self
        
        self.safariViewController = safariVC
        self.addChild(safariVC)
        self.view.addSubview(safariVC.view)
        safariVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            safariVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            safariVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            safariVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            safariVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        safariVC.didMove(toParent: self)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func doneButtonTapped() {
        self.dismiss(animated: true)
    }
}

extension CustomSafariViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.dismiss(animated: true)
    }
}
