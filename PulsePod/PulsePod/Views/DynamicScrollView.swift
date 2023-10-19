//
//  DynamicScrollView.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/12/23.
//

import SwiftUI

struct DynamicScrollView<Content: View>: UIViewRepresentable {
    let content: () -> Content
    @Binding var offset: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = context.coordinator
        let hostView = UIHostingController(rootView: content())
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostView.view)

        let constraints = [
            hostView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostView.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: DynamicScrollView

        init(_ parent: DynamicScrollView) {
            self.parent = parent
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = scrollView.contentOffset.y
        }
    }
}
