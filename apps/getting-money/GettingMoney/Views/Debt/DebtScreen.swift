import SwiftUI

/// Debt Plan: total rep debt, a per-exercise breakdown, and a "finance it over
/// N days" planner. "Pay it all off now" folds the full amount into today's
/// rounds (the proven payoff path).
struct DebtScreen: View {
  @Bindable var vm: DebtViewModel
  let onPayAll: () -> Void

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 18) {
        header
        if vm.totalDebt == 0 {
          debtFreeState
        } else {
          totalOwed
          breakdown
          financePlan
          payButton
        }
      }
      .padding(.horizontal, GMSpacing.screen)
      .padding(.top, 4)
      .padding(.bottom, 130)
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text("A calm plan back to zero")
        .font(GMFont.body(14, .semibold)).foregroundStyle(GMColor.ink.opacity(0.5))
      Text("Debt Plan")
        .font(GMFont.display(24, .bold)).foregroundStyle(GMColor.ink)
    }
  }

  private var totalOwed: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("TOTAL REP DEBT")
        .font(GMFont.body(12, .bold)).tracking(1.4)
        .foregroundStyle(GMColor.ink.opacity(0.5))
      Text(vm.totalDebt.gmDollars)
        .font(GMFont.display(50, .bold)).foregroundStyle(GMColor.debt)
        .monospacedDigit()
      Text("Pay it down with extra reps — your bank can't cover it.")
        .font(GMFont.body(13)).foregroundStyle(GMColor.ink.opacity(0.55))
        .padding(.top, 2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(24)
    .background(
      RoundedRectangle(cornerRadius: 26)
        .fill(
          LinearGradient(
            colors: [GMColor.debt.opacity(0.12), GMColor.stage.opacity(0.5)],
            startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(GMColor.debt.opacity(0.2), lineWidth: 1))
    )
    .overlay(alignment: .topTrailing) {
      Circle().fill(
        RadialGradient(
          colors: [GMColor.debt.opacity(0.2), .clear], center: .center, startRadius: 0,
          endRadius: 75)
      )
      .frame(width: 150, height: 150).offset(x: 30, y: -40).allowsHitTesting(false)
    }
    .clipShape(RoundedRectangle(cornerRadius: 26))
  }

  private var breakdown: some View {
    VStack(spacing: 10) {
      ForEach(vm.rows) { row in
        HStack(spacing: 14) {
          Image(systemName: row.glyph)
            .font(.system(size: 17, weight: .semibold)).foregroundStyle(GMColor.debt)
            .frame(width: 38, height: 38)
            .background(RoundedRectangle(cornerRadius: 11).fill(Color.black.opacity(0.3)))
          VStack(spacing: 8) {
            HStack {
              Text(row.name).font(GMFont.display(15, .bold)).foregroundStyle(GMColor.ink)
              Spacer()
              Text(row.repsOwed.gmDollars.replacingOccurrences(of: "$", with: "−$"))
                .font(GMFont.display(14, .semibold)).foregroundStyle(GMColor.debt).monospacedDigit()
            }
            GeometryReader { geo in
              ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule().fill(GMColor.debt)
                  .frame(
                    width: geo.size.width
                      * min(1, CGFloat(row.repsOwed) / CGFloat(max(row.repsOwed, 30))))
              }
            }.frame(height: 6)
          }
        }
        .padding(14)
        .background(
          RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.04))
            .overlay(
              RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.07), lineWidth: 1)))
      }
    }
  }

  private var financePlan: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Finance it over time")
        .font(GMFont.display(15, .bold)).foregroundStyle(GMColor.ink)
      Text("Spread the debt across a few days.")
        .font(GMFont.body(13)).foregroundStyle(GMColor.ink.opacity(0.55))
        .padding(.bottom, 14).padding(.top, 4)

      HStack(spacing: 7) {
        ForEach(vm.financeDayOptions, id: \.self) { d in
          let active = vm.financeDays == d && vm.planMode == .finance
          Button {
            vm.selectFinanceDays(d)
          } label: {
            Text("\(d)")
              .font(GMFont.display(16, .bold))
              .foregroundStyle(active ? GMColor.onAccent : GMColor.ink.opacity(0.55))
              .frame(maxWidth: .infinity).frame(height: 46)
              .background(
                RoundedRectangle(cornerRadius: 13).fill(
                  active ? GMColor.debt : Color.white.opacity(0.05)))
          }
          .buttonStyle(PressButtonStyle())
        }
      }
      .padding(.bottom, 18)

      HStack {
        VStack(alignment: .leading, spacing: 1) {
          Text("+\(perDayReps) reps/day")
            .font(GMFont.display(20, .bold)).foregroundStyle(GMColor.accent)
          Text("clears in \(vm.financeDays) \(vm.financeDays == 1 ? "day" : "days")")
            .font(GMFont.body(12)).foregroundStyle(GMColor.ink.opacity(0.5))
        }
        Spacer()
        HStack(spacing: 6) {
          ForEach(vm.planDays.prefix(5)) { day in
            Text("\(day.repsTotal)")
              .font(GMFont.display(11, .bold)).foregroundStyle(GMColor.accent)
              .frame(width: 30, height: 38)
              .background(
                RoundedRectangle(cornerRadius: 7).fill(GMColor.accent.opacity(0.18))
                  .overlay(
                    RoundedRectangle(cornerRadius: 7).stroke(
                      GMColor.accent.opacity(0.3), lineWidth: 1)))
          }
        }
      }
      .padding(14)
      .background(
        RoundedRectangle(cornerRadius: 14).fill(GMColor.accent.opacity(0.08))
          .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(GMColor.accent.opacity(0.2), lineWidth: 1)))
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }

  private var payButton: some View {
    Button(action: onPayAll) {
      Text("Pay it all off now")
        .font(GMFont.display(16, .bold)).foregroundStyle(GMColor.onAccent)
        .frame(maxWidth: .infinity).frame(height: 56)
        .background(RoundedRectangle(cornerRadius: 18).fill(GMColor.accent))
        .shadow(color: GMColor.accent.opacity(0.28), radius: 12, y: 8)
    }
    .buttonStyle(PressButtonStyle())
  }

  private var debtFreeState: some View {
    VStack(spacing: 14) {
      ZStack {
        Circle().stroke(GMColor.accent.opacity(0.2), lineWidth: 8).frame(width: 96, height: 96)
        Image(systemName: "checkmark")
          .font(.system(size: 40, weight: .bold)).foregroundStyle(GMColor.accent)
      }
      Text("You're debt-free")
        .font(GMFont.display(22, .bold)).foregroundStyle(GMColor.ink)
      Text("Nothing owed. Every rep from here is pure bank.")
        .font(GMFont.body(14)).foregroundStyle(GMColor.ink.opacity(0.55))
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 60)
  }

  private var perDayReps: Int { vm.planDays.map(\.repsTotal).max() ?? 0 }
}
