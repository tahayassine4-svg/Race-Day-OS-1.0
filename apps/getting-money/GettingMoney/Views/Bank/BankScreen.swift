import SwiftUI

/// Bank: the training economy at a glance — net balance, a 7-day bar chart, rep
/// flow, and debt-free progress. Read-only; all numbers come from the shared
/// engines so they agree with the dashboard.
struct BankScreen: View {
  @Bindable var vm: BankViewModel

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 18) {
        header
        filter
        net
        chart
        repFlow
        debtRing
      }
      .padding(.horizontal, GMSpacing.screen)
      .padding(.top, 4)
      .padding(.bottom, 130)
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text("Your training economy")
        .font(GMFont.body(14, .semibold)).foregroundStyle(GMColor.ink.opacity(0.5))
      Text("Bank")
        .font(GMFont.display(24, .bold)).foregroundStyle(GMColor.ink)
    }
  }

  private var filter: some View {
    HStack(spacing: 8) {
      ForEach(BankViewModel.Filter.allCases) { f in
        let active = vm.filter == f
        Button {
          vm.setFilter(f)
        } label: {
          Text(f.label)
            .font(GMFont.body(14, .bold))
            .foregroundStyle(active ? GMColor.onAccent : GMColor.ink.opacity(0.55))
            .frame(maxWidth: .infinity).frame(height: 38)
            .background(RoundedRectangle(cornerRadius: 11).fill(active ? GMColor.accent : .clear))
        }
        .buttonStyle(PressButtonStyle())
      }
    }
    .padding(5)
    .background(
      RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }

  private var net: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("NET BALANCE")
        .font(GMFont.body(12, .bold)).tracking(1.4).foregroundStyle(GMColor.ink.opacity(0.5))
      Text(vm.netMoney.gmDollars)
        .font(GMFont.display(44, .bold)).foregroundStyle(GMColor.ink).monospacedDigit()
      HStack(spacing: 18) {
        Text("+\(vm.earnedMoney.gmDollars)").foregroundStyle(GMColor.accent)
        Text(vm.lostMoney > 0 ? "−\(vm.lostMoney.gmDollars)" : "−$0").foregroundStyle(GMColor.debt)
      }
      .font(GMFont.display(15, .semibold))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(22)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(
          LinearGradient(
            colors: [GMColor.accent.opacity(0.08), GMColor.stage.opacity(0.5)],
            startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08), lineWidth: 1))
    )
  }

  private var chart: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Last 7 days")
        .font(GMFont.display(14, .bold)).foregroundStyle(GMColor.ink)
      HStack(alignment: .bottom, spacing: 8) {
        ForEach(vm.bars) { bar in
          VStack(spacing: 8) {
            GeometryReader { geo in
              VStack {
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 6)
                  .fill(bar.isToday ? GMColor.accent : GMColor.accent.opacity(0.28))
                  .frame(height: max(6, geo.size.height * bar.heightFraction))
                  .shadow(color: bar.isToday ? GMColor.accent.opacity(0.5) : .clear, radius: 8)
              }
            }
            .frame(maxWidth: .infinity)
            Text(bar.label)
              .font(GMFont.body(11, .semibold)).foregroundStyle(GMColor.ink.opacity(0.4))
          }
        }
      }
      .frame(height: 120)
    }
    .padding(.vertical, 20).padding(.horizontal, 18)
    .background(
      RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }

  private var repFlow: some View {
    let earned = max(1, vm.earnedMoney)
    let flows: [(String, Int, Double, Color)] = [
      ("Reps earned", vm.earnedMoney, 1.0, GMColor.accent),
      (
        "Bonus bank", vm.bonusMoney, min(1, Double(vm.bonusMoney) / Double(earned)),
        GMColor.accentDeep
      ),
      (
        "Missed reps", vm.lostMoney,
        vm.lostMoney > 0 ? max(0.05, min(1, Double(vm.lostMoney) / Double(earned))) : 0.02,
        GMColor.debt
      ),
    ]
    return VStack(alignment: .leading, spacing: 16) {
      Text("Rep flow").font(GMFont.display(14, .bold)).foregroundStyle(GMColor.ink)
      ForEach(flows, id: \.0) { label, amount, width, color in
        VStack(spacing: 7) {
          HStack {
            Text(label).font(GMFont.body(13, .semibold)).foregroundStyle(GMColor.ink.opacity(0.65))
            Spacer()
            Text((label == "Missed reps" && amount > 0 ? "−" : "+") + amount.gmDollars)
              .font(GMFont.display(13, .semibold)).foregroundStyle(color).monospacedDigit()
          }
          GeometryReader { geo in
            ZStack(alignment: .leading) {
              Capsule().fill(Color.white.opacity(0.06))
              Capsule().fill(color).frame(width: geo.size.width * width)
            }
          }.frame(height: 8)
        }
      }
    }
    .padding(.vertical, 20).padding(.horizontal, 18)
    .background(
      RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }

  private var debtRing: some View {
    HStack(spacing: 18) {
      ZStack {
        Circle().stroke(GMColor.debt.opacity(0.15), lineWidth: 7)
        Circle()
          .trim(from: 0, to: CGFloat(vm.debtFreePercent) / 100)
          .stroke(GMColor.accent, style: StrokeStyle(lineWidth: 7, lineCap: .round))
          .rotationEffect(.degrees(-90))
        Text("\(vm.debtFreePercent)%")
          .font(GMFont.display(15, .bold)).foregroundStyle(GMColor.accent)
      }
      .frame(width: 74, height: 74)
      VStack(alignment: .leading, spacing: 2) {
        Text("Debt-free progress")
          .font(GMFont.display(15, .bold)).foregroundStyle(GMColor.ink)
        Text(vm.debtFreeLabel)
          .font(GMFont.body(13)).foregroundStyle(GMColor.ink.opacity(0.55))
      }
      Spacer()
    }
    .padding(.vertical, 20).padding(.horizontal, 18)
    .background(
      RoundedRectangle(cornerRadius: 22).fill(Color.white.opacity(0.04))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
  }
}
