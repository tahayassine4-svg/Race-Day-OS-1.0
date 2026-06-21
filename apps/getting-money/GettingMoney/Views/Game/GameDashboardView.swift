import SwiftUI

struct GameDashboardView: View {
  var vm: GameSessionViewModel

  @State private var animController = CharacterAnimationController()

  var body: some View {
    VStack(spacing: 0) {
      hudBar
      exerciseSelector
      progressRow
      arenaSection
      tapHint
      sessionStrip
      dailyConsole
    }
    .background(GMColor.background)
    .onAppear { vm.load() }
    .onDisappear { vm.flushSession() }
  }

  // MARK: - HUD Bar

  private var hudBar: some View {
    HStack {
      HStack(spacing: 5) {
        Image("pixel_icon_flame")
          .pixelArt()
          .frame(width: 18, height: 26)
        Text("\(vm.streakDays)")
          .font(.system(size: 16, weight: .heavy, design: .monospaced))
          .foregroundStyle(GMColor.ink)
      }
      Spacer()
      HStack(spacing: 4) {
        Image("pixel_icon_coin")
          .pixelArt()
          .frame(width: 16, height: 18)
        Text(vm.earnedCoins.gmCoins)
          .font(.system(size: 16, weight: .heavy, design: .monospaced))
          .foregroundStyle(Color(hex: "#FFD700"))
      }
      if vm.debtCoins > 0 {
        Text("-\(vm.debtCoins.gmCoins)")
          .font(.system(size: 11, weight: .heavy, design: .monospaced))
          .foregroundStyle(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(GMColor.debt)
          .clipShape(RoundedRectangle(cornerRadius: 2))
      }
    }
    .padding(.horizontal, 20)
    .frame(height: 48)
    .background(GMColor.surface)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(GMColor.hairline)
        .frame(height: 1.5)
    }
  }

  // MARK: - Exercise Selector

  private var exerciseSelector: some View {
    HStack(spacing: 0) {
      ForEach(vm.exercises, id: \.key) { ex in
        let isActive = vm.selectedExercise?.key == ex.key
        Button {
          vm.switchExercise(ex)
        } label: {
          Text(ex.name.uppercased())
            .font(.system(size: 11, weight: .heavy, design: .monospaced))
            .foregroundStyle(isActive ? GMColor.onAccent : GMColor.muted)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(isActive ? GMColor.accent : GMColor.surface)
            .overlay(
              Rectangle()
                .strokeBorder(GMColor.hairline, lineWidth: 1.5)
            )
        }
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 2))
    .padding(.horizontal, 20)
    .padding(.top, 10)
    .padding(.bottom, 8)
  }

  // MARK: - Progress Row

  private var progressRow: some View {
    HStack(spacing: 12) {
      PixelProgressBar(fraction: selectedFraction)
      Text("\(selectedCompleted) / \(selectedTarget)")
        .font(.system(size: 11, weight: .heavy, design: .monospaced))
        .foregroundStyle(GMColor.muted)
        .fixedSize()
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 10)
  }

  // MARK: - Arena

  private var arenaSection: some View {
    ZStack(alignment: .bottom) {
      // Ground strip
      Rectangle()
        .fill(Color(hex: "#1A2020"))
        .frame(height: 12)
        .frame(maxWidth: .infinity)

      // Depth stage line just above ground
      Rectangle()
        .fill(GMColor.hairline)
        .frame(height: 1.5)
        .frame(maxWidth: .infinity)
        .offset(y: -12)

      // Character — tap triggers animation and rep
      PixelCharacterView(controller: animController, size: 552) {
        let fps = vm.tapRep()
        if let ex = vm.selectedExercise {
          animController.triggerExercise(ex.characterAnimation, fps: fps)
        }
      }
      .padding(.bottom, 14)

      // Level badge — bottom leading corner
      VStack {
        Spacer()
        HStack {
          Image("pixel_level_badge")
            .pixelArt()
            .frame(height: 28)
            .padding(.leading, 16)
            .padding(.bottom, 20)
          Spacer()
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(GMColor.background)
    .clipped()
  }

  // MARK: - Tap Hint

  private var tapHint: some View {
    HStack(spacing: 6) {
      Rectangle()
        .fill(GMColor.muted.opacity(0.6))
        .frame(width: 4, height: 4)
      Text("TAP TO REP")
        .font(.system(size: 12, weight: .semibold, design: .monospaced))
        .foregroundStyle(GMColor.muted)
        .kerning(1.5)
      Rectangle()
        .fill(GMColor.muted.opacity(0.6))
        .frame(width: 4, height: 4)
    }
    .frame(height: 28)
  }

  // MARK: - Session Strip

  private var sessionStrip: some View {
    let sessionTotal = vm.sessionRepsByExercise.values.reduce(0, +)
    return HStack(spacing: 6) {
      Text("+\(sessionTotal) REPS THIS SESSION")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(GMColor.muted)
      if sessionTotal > 0 {
        Text("·")
          .foregroundStyle(GMColor.hairline)
          .font(.system(size: 11))
        HStack(spacing: 3) {
          PixelCoinView(size: 11)
          Text("+\(sessionTotal)")
            .font(.system(size: 11, weight: .heavy, design: .monospaced))
            .foregroundStyle(GMColor.accent)
        }
      }
    }
    .frame(height: 28)
  }

  private var dailyConsole: some View {
    let completed = completedToday.values.reduce(0, +)
    let target = targetsToday.values.reduce(0, +)
    return VStack(alignment: .leading, spacing: 7) {
      HStack {
        Text("DAILY PROGRESS")
          .font(.system(size: 10, weight: .heavy, design: .monospaced))
          .foregroundStyle(GMColor.muted)
        Spacer()
        Text("\(completed.gmGrouped) / \(target.gmGrouped)")
          .font(.system(size: 10, weight: .heavy, design: .monospaced))
          .foregroundStyle(GMColor.muted)
      }
      GMProgressBar(fraction: target > 0 ? Double(completed) / Double(target) : 0, height: 11)
      HStack {
        consoleMetric(title: "STREAK", value: "\(vm.streakDays)d")
        Spacer()
        consoleMetric(title: "COINS", value: vm.earnedCoins.gmCoins)
        Spacer()
        consoleMetric(title: "DEBT", value: vm.debtCoins > 0 ? vm.debtCoins.gmCoins : "CLEAR")
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
    .background(GMColor.surface)
    .overlay(alignment: .top) {
      Rectangle().fill(GMColor.hairline).frame(height: 1)
    }
  }

  private func consoleMetric(title: String, value: String) -> some View {
    VStack(spacing: 2) {
      Text(title)
        .font(.system(size: 9, weight: .heavy, design: .monospaced))
        .foregroundStyle(GMColor.muted)
      Text(value)
        .font(.system(size: 12, weight: .heavy, design: .monospaced))
        .foregroundStyle(GMColor.ink)
    }
  }

  // MARK: - Helpers

  private var selectedFraction: Double {
    guard let ex = vm.selectedExercise else { return 0 }
    let t = vm.targetsToday[ex.key] ?? 0
    let c = vm.completedToday[ex.key] ?? 0
    guard t > 0 else { return 0 }
    return min(1.0, Double(c) / Double(t))
  }

  private var completedToday: [String: Int] { vm.completedToday }
  private var targetsToday: [String: Int] { vm.targetsToday }

  private var selectedCompleted: Int {
    guard let ex = vm.selectedExercise else { return 0 }
    return vm.completedToday[ex.key] ?? 0
  }

  private var selectedTarget: Int {
    guard let ex = vm.selectedExercise else { return 0 }
    return vm.targetsToday[ex.key] ?? 0
  }
}

// MARK: - Pixel Progress Bar

struct PixelProgressBar: View {
  var fraction: Double

  var body: some View {
    HStack(spacing: 2) {
      ForEach(0..<20, id: \.self) { i in
        let filled = Double(i) / 20.0 < fraction
        RoundedRectangle(cornerRadius: 1)
          .fill(filled ? GMColor.accent : GMColor.elevated)
          .frame(width: 10, height: 16)
          .overlay(
            RoundedRectangle(cornerRadius: 1)
              .strokeBorder(GMColor.hairline, lineWidth: filled ? 0 : 1)
          )
      }
    }
  }
}
