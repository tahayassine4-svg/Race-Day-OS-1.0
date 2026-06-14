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
        .task { viewModel.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: GMSpacing.xs) {
            Text("LOG · TODAY")
                .font(.system(size: 12, weight: .semibold)).tracking(1.4)
                .foregroundStyle(GMColor.muted)
            HStack(alignment: .top) {
                Text("Log your reps.")
                    .font(.gmTitle).foregroundStyle(GMColor.ink)
                Spacer()
                GMStatusPill(status: viewModel.status)
            }
        }
    }

    private var earnedCard: some View {
        GMCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("EARNED TODAY")
                        .font(.system(size: 12, weight: .semibold)).tracking(1.2)
                        .foregroundStyle(GMColor.muted)
                    Text("+" + viewModel.earnedToday.gmMoney)
                        .font(.system(size: 34, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(GMColor.accent)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Reps logged").font(.system(size: 13, weight: .medium)).foregroundStyle(GMColor.muted)
                    (Text(viewModel.loggedToday.gmGrouped).foregroundStyle(GMColor.ink)
                     + Text(" / \(viewModel.dailyTarget.gmGrouped)").foregroundStyle(GMColor.muted))
                        .font(.system(size: 16, weight: .bold)).monospacedDigit()
                }
            }
        }
    }

    private var saveCTA: some View {
        Button { viewModel.save() } label: {
            HStack(spacing: 8) {
                Text("Save reps").font(.system(size: 17, weight: .bold))
                Text("· +\(viewModel.draftTotal.gmMoney) today")
                    .font(.system(size: 13, weight: .semibold)).opacity(0.62)
            }
            .foregroundStyle(GMColor.onAccent)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GMColor.accent))
        }
        .disabled(viewModel.draftTotal == 0)
        .opacity(viewModel.draftTotal == 0 ? 0.55 : 1)
        .gmScreenPadding()
        .padding(.top, GMSpacing.md)
        .padding(.bottom, GMSpacing.sm)
        .background(.ultraThinMaterial)
    }
}
