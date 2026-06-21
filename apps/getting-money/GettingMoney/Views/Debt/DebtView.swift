import SwiftUI

struct DebtView: View {
  let viewModel: DebtViewModel
  var onAddPayoff: () -> Void = {}

  var body: some View {
    ZStack {
      ScreenBackground()
      ScrollView {
        VStack(alignment: .leading, spacing: GMSpacing.lg) {
          header
          debtOfficeNPC
          debtHero
          if viewModel.totalDebt > 0 {
            planToggle
            if viewModel.planMode == .finance { financeDaysRow }
          }
          planCard
          sectionHeader
          breakdown
          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage).font(.gmMeta).foregroundStyle(GMColor.debt)
          }
        }
        .gmScreenPadding()
        .padding(.top, GMSpacing.xs)
        .padding(.bottom, 112)
      }
    }
    .safeAreaInset(edge: .bottom) { bottomCTA }
    .task { viewModel.load() }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: GMSpacing.xs) {
      Text("DEBT OFFICE")
        .font(.system(size: 12, weight: .heavy, design: .monospaced)).tracking(1.4)
        .foregroundStyle(GMColor.muted)
      HStack(alignment: .top) {
        Text("Rep now,\nrepay later.")
          .font(.gmTitle).foregroundStyle(GMColor.ink)
        Spacer()
        GMStatusPill(status: viewModel.status)
      }
    }
  }

  private var debtOfficeNPC: some View {
    GMCard(padding: 0, tint: GMColor.stage, border: GMColor.parchmentLine.opacity(0.45)) {
      ZStack(alignment: .bottom) {
        PixelNoise(color: GMColor.parchmentLine.opacity(0.08), spacing: 7)
        VStack(spacing: 0) {
          GMParchmentCard(padding: 9) {
            Text(
              viewModel.totalDebt > 0
                ? "Hey player, your payoff plan's ready. Sign and commit."
                : "All clear. No debt outstanding. Keep the streak clean!"
            )
            .font(.system(size: 11, weight: .heavy, design: .monospaced))
            .multilineTextAlignment(.center)
            .foregroundStyle(GMColor.parchmentInk)
            .frame(maxWidth: .infinity)
          }
          .padding(.horizontal, 24)
          Spacer()
        }
        HStack(alignment: .bottom, spacing: 8) {
          Image("banker_front")
            .pixelArt()
            .frame(height: 110)
          Image("banker_lamp")
            .pixelArt()
            .frame(height: 40)
          Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
      }
      .frame(height: 170)
    }
  }

  private var debtHero: some View {
    GMCard {
      VStack(spacing: 7) {
        Text("CURRENT REP DEBT")
          .font(.system(size: 12, weight: .semibold)).tracking(1.2)
          .foregroundStyle(GMColor.muted)
        HStack(spacing: 8) {
          Image("pixel_debt_coin")
            .pixelArt()
            .frame(width: 30, height: 30)
          Text(viewModel.totalDebt.gmCoins)
            .font(.system(size: 44, weight: .heavy, design: .monospaced))
            .monospacedDigit()
            .foregroundStyle(viewModel.totalDebt > 0 ? GMColor.debt : GMColor.success)
          Spacer()
        }
        (Text(viewModel.totalDebt.gmGrouped).foregroundStyle(GMColor.ink)
          + Text(" reps owed · paid back in reps, not money").foregroundStyle(GMColor.muted))
          .font(.system(size: 14, weight: .semibold))
          .monospacedDigit()
      }
      .frame(maxWidth: .infinity)
    }
    .background(Rectangle().fill(GMColor.debt.opacity(0.08)))
  }

  private var planToggle: some View {
    HStack(spacing: 6) {
      planOption(title: "Pay in one go", isActive: viewModel.planMode == .oneGo) {
        viewModel.selectMode(.oneGo)
      }
      planOption(title: "Finance plan", isActive: viewModel.planMode == .finance) {
        viewModel.selectMode(.finance)
      }
    }
    .padding(5)
    .background(Rectangle().fill(GMColor.elevated))
    .overlay(Rectangle().stroke(GMColor.hairline, lineWidth: 1))
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Payback strategy")
  }

  private func planOption(title: String, isActive: Bool, action: @escaping () -> Void) -> some View
  {
    Button(action: action) {
      Text(title)
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(isActive ? GMColor.debt : GMColor.muted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
          Rectangle().fill(
            GMColor.debt.opacity(isActive ? 0.16 : 0)))
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isActive ? .isSelected : [])
  }

  private var financeDaysRow: some View {
    HStack(spacing: 9) {
      Text("SPREAD OVER")
        .font(.system(size: 12, weight: .semibold)).tracking(0.5)
        .foregroundStyle(GMColor.muted)
      Spacer()
      ForEach(viewModel.financeDayOptions, id: \.self) { days in
        Button {
          viewModel.selectFinanceDays(days)
        } label: {
          Text("\(days)")
            .font(.system(size: 15, weight: .heavy)).monospacedDigit()
            .foregroundStyle(days == viewModel.financeDays ? GMColor.debt : GMColor.muted)
            .frame(width: 40, height: 36)
            .background(Rectangle().fill(GMColor.elevated))
            .overlay(
              Rectangle()
                .stroke(
                  days == viewModel.financeDays ? GMColor.debt.opacity(0.4) : GMColor.hairline,
                  lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Spread over \(days) days")
        .accessibilityAddTraits(days == viewModel.financeDays ? .isSelected : [])
      }
    }
  }

  private var planCard: some View {
    GMCard(padding: 0) {
      VStack(spacing: 0) {
        if viewModel.planDays.isEmpty {
          Text("No payoff plan needed.")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(GMColor.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        } else {
          ForEach(Array(viewModel.planDays.enumerated()), id: \.element.id) { index, day in
            if index > 0 { Divider().overlay(GMColor.hairline) }
            PlanDayRow(day: day)
          }
        }
      }
    }
  }

  private var sectionHeader: some View {
    Text("DEBT BREAKDOWN").font(.gmSection).tracking(0.4).foregroundStyle(GMColor.muted)
  }

  private var breakdown: some View {
    GMCard(padding: 0) {
      VStack(spacing: 0) {
        if viewModel.rows.isEmpty {
          Text("All clear. Keep the streak clean.")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(GMColor.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        } else {
          ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { index, row in
            if index > 0 { Divider().overlay(GMColor.hairline) }
            DebtBreakdownRow(row: row)
          }
        }
      }
    }
  }

  private var bottomCTA: some View {
    VStack(spacing: 7) {
      Button {
        onAddPayoff()
      } label: {
        Text("Add payoff to today's rounds")
          .font(.system(size: 17, weight: .bold))
          .foregroundStyle(GMColor.onAccent)
          .frame(maxWidth: .infinity).frame(height: 56)
          .background(RoundedRectangle(cornerRadius: 4).fill(GMColor.accent))
          .overlay(Rectangle().stroke(GMColor.hotline, lineWidth: 2))
      }
      .disabled(viewModel.totalDebt == 0)
      .opacity(viewModel.totalDebt == 0 ? 0.55 : 1)
      .accessibilityLabel("Add debt payoff to today's rounds")
      Text("Money can't clear debt — only reps can.")
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(GMColor.muted)
    }
    .gmScreenPadding()
    .padding(.top, GMSpacing.md)
    .padding(.bottom, GMSpacing.sm)
    .background(GMColor.background.opacity(0.94))
  }
}

private struct PlanDayRow: View {
  let day: DebtViewModel.PlanDay

  var body: some View {
    HStack(spacing: GMSpacing.md) {
      Text("\(day.id)")
        .font(.system(size: 14, weight: .bold)).foregroundStyle(GMColor.muted)
        .frame(width: 34, height: 34)
        .background(Rectangle().fill(GMColor.elevated))
        .overlay(Rectangle().stroke(GMColor.hairline, lineWidth: 1))
      Text(day.title).font(.system(size: 16, weight: .bold)).foregroundStyle(GMColor.ink)
      Spacer()
      VStack(alignment: .trailing, spacing: 2) {
        Text(day.summary)
          .font(.system(size: 13, weight: .bold))
          .foregroundStyle(GMColor.accent)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Text("\(day.repsTotal) reps")
          .font(.system(size: 11, weight: .semibold)).monospacedDigit()
          .foregroundStyle(GMColor.muted)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 11)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(day.title): \(day.repsTotal) reps. \(day.summary)")
  }
}

private struct DebtBreakdownRow: View {
  let row: DebtViewModel.Row

  private var exerciseImageName: String {
    switch row.id {
    case "pushups": return "pixel_exercise_pushups"
    case "pullups": return "pixel_exercise_pullups"
    case "squats": return "pixel_exercise_squats"
    case "dips": return "pixel_exercise_dips"
    default:
      assertionFailure("Unknown exercise key: \(row.id)")
      return "pixel_exercise_pushups"
    }
  }

  var body: some View {
    HStack(spacing: GMSpacing.md) {
      Image(exerciseImageName)
        .pixelArt()
        .frame(width: 38, height: 44)
      Text(row.name).font(.system(size: 17, weight: .bold)).foregroundStyle(GMColor.ink)
      Spacer()
      Text(row.repsOwed.gmGrouped)
        .font(.system(size: 17, weight: .heavy))
        .monospacedDigit()
        .foregroundStyle(GMColor.debt)
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 13)
  }
}
