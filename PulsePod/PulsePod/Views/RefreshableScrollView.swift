//
//  RefreshableScrollView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/12/23.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    
    let width: CGFloat
    let height: CGFloat
    let content: Content
    let onRefresh: () -> Void

    init(width: CGFloat, height: CGFloat, onRefresh: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.width = width
        self.height = height
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
        
        let hostView = UIHostingController(rootView: content.frame(width: width, height: height))
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostView.view)
        
        NSLayoutConstraint.activate([
            hostView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        scrollView.refreshControl = refreshControl
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onRefresh: onRefresh)
    }
    
    class Coordinator: NSObject {
        let onRefresh: () -> Void
        
        init(onRefresh: @escaping () -> Void) {
            self.onRefresh = onRefresh
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            onRefresh()
            sender.endRefreshing()
        }
    }
}
