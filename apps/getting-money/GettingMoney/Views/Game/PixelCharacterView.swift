import SwiftUI

enum CharacterAnimation: String {
  case idle = "idle"
  case pushup = "pushup"
  case squat = "squat"
  case pullup = "pullup"

  var frameCount: Int {
    switch self {
    case .idle: return 9
    case .pushup: return 9
    case .squat: return 9
    case .pullup: return 17
    }
  }

  var prefix: String { "char_\(rawValue)_" }

  func frameName(_ index: Int) -> String {
    "\(prefix)\(String(format: "%03d", index))"
  }
}

@Observable
@MainActor
final class CharacterAnimationController {
  private(set) var animation: CharacterAnimation = .idle
  private(set) var frame: Int = 0
  private var timer: Timer?
  private var isLooping: Bool = true
  private var pendingAnimation: CharacterAnimation?

  func triggerExercise(_ anim: CharacterAnimation, fps: Double = 10) {
    guard anim != .idle else { return }
    if !isLooping {
      pendingAnimation = anim
      return
    }
    startAnimation(anim, looping: false, fps: fps)
  }

  private func startAnimation(_ anim: CharacterAnimation, looping: Bool, fps: Double) {
    timer?.invalidate()
    animation = anim
    frame = 0
    isLooping = looping
    restartTimer(fps: fps)
  }

  private func restartTimer(fps: Double) {
    timer?.invalidate()
    let interval = 1.0 / max(fps, 1)
    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
      Task { @MainActor [weak self] in self?.advance() }
    }
  }

  private func advance() {
    frame += 1
    if frame >= animation.frameCount {
      if isLooping {
        frame = 0
      } else {
        if let next = pendingAnimation {
          pendingAnimation = nil
          startAnimation(next, looping: false, fps: 10)
        } else {
          startAnimation(.idle, looping: true, fps: 8)
        }
      }
    }
  }
}

extension Exercise {
  var characterAnimation: CharacterAnimation {
    switch key {
    case "pushups": return .pushup
    case "squats": return .squat
    case "pullups": return .pullup
    default: return .idle
    }
  }
}

struct PixelCharacterView: View {
  var controller: CharacterAnimationController
  var size: CGFloat = 320
  var onTap: () -> Void

  var body: some View {
    let name = controller.animation.frameName(controller.frame)
    Image(name)
      .interpolation(.none)
      .resizable()
      .frame(width: size, height: size)
      .contentShape(Rectangle())
      .onTapGesture(perform: onTap)
  }
}
