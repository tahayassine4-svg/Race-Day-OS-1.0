import SwiftUI

struct LogView: View {
  let viewModel: RepLoggerViewModel
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    ZStack {
      ScreenBackground()
      ScrollView {
        VStack(alignment: .leading, spacing: GMSpacing.lg) {
          header
          earnedCard
          ForEach(viewModel.rows) { row in
            LogExerciseCard(row: row, viewModel: viewModel, reduceMotion: reduceMotion)
          }
          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage).font(.gmMeta).foregroundStyle(GMColor.debt)
          }
        }
        .gmScreenPadding()
        .padding(.top, GMSpacing.xs)
        .padding(.bottom, 112)
      }
    }
    .safeAreaInset(edge: .bottom) { saveCTA }
    .sensoryFeedback(.selection, trigger: viewModel.feedbackTick)
    .task { viewModel.load(today: viewModel.selectedDate) }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: GMSpacing.xs) {
      HStack(spacing: GMSpacing.sm) {
        Image("paper_clipboard_clip")
          .pixelArt()
          .frame(width: 32, height: 16)
        Text(viewModel.logEyebrow)
          .font(.system(size: 12, weight: .heavy, design: .monospaced)).tracking(1.4)
          .foregroundStyle(GMColor.muted)
      }
      HStack(alignment: .top) {
        Text("SESSION LOG")
          .font(.gmTitle).foregroundStyle(GMColor.ink)
        Spacer()
        GMStatusPill(status: viewModel.status)
      }
      Text("Track every rep.")
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(GMColor.muted)
    }
  }

  private var earnedCard: some View {
    GMCard(border: GMColor.hotline.opacity(0.8)) {
      HStack {
        VStack(alignment: .leading, spacing: 6) {
          Text(viewModel.earnedTitle)
            .font(.system(size: 12, weight: .heavy, design: .monospaced)).tracking(1.2)
            .foregroundStyle(GMColor.muted)
          HStack(spacing: 6) {
            PixelCoinView(size: 24)
            Text("+" + viewModel.earnedToday.gmCoins)
              .font(.system(size: 32, weight: .heavy, design: .monospaced))
              .monospacedDigit()
              .foregroundStyle(GMColor.accent)
          }
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 5) {
          Text("Reps logged").font(.system(size: 13, weight: .medium)).foregroundStyle(
            GMColor.muted)
          (Text(viewModel.loggedToday.gmGrouped).foregroundStyle(GMColor.ink)
            + Text(" / \(viewModel.dailyTarget.gmGrouped)").foregroundStyle(GMColor.muted))
            .font(.system(size: 16, weight: .bold)).monospacedDigit()
        }
      }
    }
  }

  private var saveCTA: some View {
    Button {
      viewModel.save()
    } label: {
      HStack(spacing: 8) {
        Text(viewModel.saveTitle).font(.system(size: 17, weight: .bold))
        Text("· \(viewModel.saveSubtitle)")
          .font(.system(size: 13, weight: .semibold)).opacity(0.62)
      }
      .foregroundStyle(GMColor.onAccent)
      .frame(maxWidth: .infinity).frame(height: 56)
      .background(Rectangle().fill(GMColor.accent))
      .overlay(Rectangle().stroke(GMColor.hotline, lineWidth: 2))
    }
    .disabled(!viewModel.hasPendingChanges)
    .opacity(viewModel.hasPendingChanges ? 1 : 0.55)
    .gmScreenPadding()
    .padding(.top, GMSpacing.md)
    .padding(.bottom, GMSpacing.sm)
    .background(GMColor.background.opacity(0.94))
  }
}
