type Props = {
  totalCal: number
  totalFluid: number
  totalSodium: number
}

export function FuelSummary({ totalCal, totalFluid, totalSodium }: Props) {
  return (
    <div className="rounded-lg border bg-card p-4">
      <p className="text-sm font-medium mb-3">Race totals</p>
      <div className="grid grid-cols-3 gap-4">
        <div>
          <p className="text-2xl font-bold tabular-nums">{totalCal.toLocaleString()}</p>
          <p className="text-xs text-muted-foreground mt-0.5">kcal</p>
        </div>
        <div>
          <p className="text-2xl font-bold tabular-nums">
            {totalFluid >= 1000
              ? `${(totalFluid / 1000).toFixed(1)}L`
              : `${totalFluid}ml`}
          </p>
          <p className="text-xs text-muted-foreground mt-0.5">fluid</p>
        </div>
        <div>
          <p className="text-2xl font-bold tabular-nums">
            {totalSodium >= 1000
              ? `${(totalSodium / 1000).toFixed(1)}g`
              : `${totalSodium}mg`}
          </p>
          <p className="text-xs text-muted-foreground mt-0.5">sodium</p>
        </div>
      </div>
    </div>
  )
}
