import SwiftUI

/// App-wide earnings-toast coordinator. Screens call `show(_:_:)` after logging;
/// the root hosts the single toast overlay so it floats above the tab bar.
@Observable
@MainActor
final class ToastCenter {
  private(set) var current: GMToast?
  private var clearTask: Task<Void, Never>?

  func show(_ main: String, _ sub: String) {
    clearTask?.cancel()
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
      current = GMToast(main: main, sub: sub)
    }
    clearTask = Task { @MainActor [weak self] in
      try? await Task.sleep(for: .seconds(2.4))
      guard !Task.isCancelled else { return }
      withAnimation(.easeOut(duration: 0.3)) { self?.current = nil }
    }
  }
}
