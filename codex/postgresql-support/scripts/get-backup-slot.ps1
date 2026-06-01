param(
    [datetime]$Date = (Get-Date),
    [string]$Prefix = "ai_platform",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

# Monday=1 ... Sunday=7
$dayOfWeek = [int]$Date.DayOfWeek
$weekSlot = if ($dayOfWeek -eq 0) { 7 } else { $dayOfWeek }
$day = $Date.Day

$files = @()
$files += [pscustomobject]@{
    Cycle = "weekly"
    Slot = "semana_$weekSlot"
    FileName = "{0}_semana_{1}.dump" -f $Prefix, $weekSlot
}

if ($day -eq 1 -or $day -eq 15) {
    $files += [pscustomobject]@{
        Cycle = "fortnightly"
        Slot = "dia_{0:00}" -f $day
        FileName = "{0}_quinzenal_dia_{1:00}.dump" -f $Prefix, $day
    }
}

if ($day -eq 1) {
    $files += [pscustomobject]@{
        Cycle = "monthly"
        Slot = "dia_01"
        FileName = "{0}_mensal_dia_01.dump" -f $Prefix
    }
}

$result = [pscustomobject]@{
    Date = $Date.ToString("yyyy-MM-dd")
    Prefix = $Prefix
    WeekSlot = $weekSlot
    Files = $files
}

if ($Json) {
    $result | ConvertTo-Json -Depth 5
} else {
    $result
}
