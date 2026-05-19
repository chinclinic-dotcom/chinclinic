# Regenerate favicon PNGs from assets/logo.png (tight crop, minimal padding)
Add-Type -AssemblyName System.Drawing

function Get-WordmarkStartX([System.Drawing.Bitmap]$bitmap) {
  # Black wordmark sits in the middle band; ignore icon silhouette elsewhere
  $w = $bitmap.Width
  $h = $bitmap.Height
  $y0 = [int]($h * 0.38)
  $y1 = [int]($h * 0.56)
  $step = [Math]::Max(1, [int](($y1 - $y0) / 40))
  for ($x = [int]($w * 0.32); $x -lt $w; $x++) {
    $dark = 0
    $samples = 0
    for ($y = $y0; $y -lt $y1; $y += $step) {
      $samples++
      $c = $bitmap.GetPixel($x, $y)
      $isText = ($c.R -lt 50) -and ($c.G -lt 50) -and ($c.B -lt 50) -and ([Math]::Abs($c.R - $c.G) -lt 20)
      if ($isText) { $dark++ }
    }
    if ($samples -gt 0 -and ($dark / $samples) -gt 0.2) { return $x - 8 }
  }
  return [int]($w * 0.52)
}

function Get-IconBounds([System.Drawing.Bitmap]$bitmap) {
  $w = $bitmap.Width
  $h = $bitmap.Height
  $maxX = Get-WordmarkStartX $bitmap
  $minX = $w
  $minY = $h
  $maxY = 0
  $iconMaxX = 0
  for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $maxX; $x++) {
      $c = $bitmap.GetPixel($x, $y)
      if ($c.A -lt 12) { continue }
      $isTeal = ($c.G -gt $c.R + 6) -and ($c.B -ge $c.R - 5) -and ($c.G -gt 75) -and ($c.R -lt 130)
      $isDarkTeal = ($c.R -lt 95) -and ($c.G -gt 65) -and ($c.B -gt 65) -and ($c.G -ge $c.R)
      if ($isTeal -or $isDarkTeal) {
        if ($x -lt $minX) { $minX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($x -gt $iconMaxX) { $iconMaxX = $x }
        if ($y -gt $maxY) { $maxY = $y }
      }
    }
  }
  if ($iconMaxX -lt $minX) { return $null }
  $pad = [int][Math]::Max(3, [Math]::Round(($iconMaxX - $minX) * 0.015))
  $x1 = [Math]::Max(0, $minX - $pad)
  $y1 = [Math]::Max(0, $minY - $pad)
  $x2 = [Math]::Min($maxX, $iconMaxX + $pad + 1)
  $y2 = [Math]::Min($h, $maxY + $pad + 1)
  return [System.Drawing.Rectangle]::FromLTRB($x1, $y1, $x2, $y2)
}

function Get-ContentBounds([System.Drawing.Bitmap]$bitmap, [int]$threshold = 250) {
  $w = $bitmap.Width
  $h = $bitmap.Height
  $minX = $w
  $minY = $h
  $maxX = 0
  $maxY = 0
  for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
      $c = $bitmap.GetPixel($x, $y)
      if ($c.A -lt 12) { continue }
      $lum = [int](0.299 * $c.R + 0.587 * $c.G + 0.114 * $c.B)
      if ($lum -lt $threshold) {
        if ($x -lt $minX) { $minX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($x -gt $maxX) { $maxX = $x }
        if ($y -gt $maxY) { $maxY = $y }
      }
    }
  }
  if ($maxX -lt $minX) { return $null }
  return [System.Drawing.Rectangle]::FromLTRB($minX, $minY, $maxX + 1, $maxY + 1)
}

function Copy-Region([System.Drawing.Bitmap]$src, [System.Drawing.Rectangle]$region) {
  $out = New-Object System.Drawing.Bitmap $region.Width, $region.Height
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.DrawImage($src, 0, 0, $region, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  return $out
}

function To-Square([System.Drawing.Bitmap]$bmp, [double]$padRatio = 0.03) {
  $w = $bmp.Width
  $h = $bmp.Height
  $side = [Math]::Max($w, $h)
  $pad = [int][Math]::Max(2, [Math]::Ceiling($side * $padRatio))
  $canvas = $side + ($pad * 2)
  $out = New-Object System.Drawing.Bitmap $canvas, $canvas
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.Clear([System.Drawing.Color]::White)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $x = [int](($canvas - $w) / 2)
  $y = [int](($canvas - $h) / 2)
  $g.DrawImage($bmp, $x, $y, $w, $h)
  $g.Dispose()
  return $out
}

function Save-Icon([System.Drawing.Bitmap]$bmp, [string]$path, [int]$size) {
  $out = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.Clear([System.Drawing.Color]::White)
  # Small inset so the mark fills the tab without clipping
  $inset = [Math]::Max(1, [int][Math]::Round($size * 0.04))
  $draw = $size - ($inset * 2)
  $g.DrawImage($bmp, $inset, $inset, $draw, $draw)
  $g.Dispose()
  $out.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose()
}

$assets = if (Test-Path (Join-Path $PSScriptRoot "..\assets\logo.png")) {
  (Resolve-Path (Join-Path $PSScriptRoot "..\assets")).Path
} else {
  (Resolve-Path "assets").Path
}

$logoPath = Join-Path $assets "logo.png"
$src = [System.Drawing.Bitmap]::FromFile($logoPath)

$bounds = Get-IconBounds $src
if ($null -eq $bounds) {
  Write-Warning "Teal detection failed; falling back to luminance trim on left half"
  $iconW = [int]($src.Width * 0.4)
  $bounds = Get-ContentBounds (Copy-Region $src ([System.Drawing.Rectangle]::FromLTRB(0, 0, $iconW, $src.Height)))
}
Write-Host "Icon bounds: $($bounds.X),$($bounds.Y) $($bounds.Width)x$($bounds.Height)"

$trimmed = Copy-Region $src $bounds
$src.Dispose()

# Trim near-white margins (repeat for tightest box)
foreach ($thresh in @(252, 254)) {
  $inner = Get-ContentBounds $trimmed $thresh
  if ($null -ne $inner -and $inner.Width -gt 8 -and $inner.Height -gt 8) {
    $tighter = Copy-Region $trimmed $inner
    $trimmed.Dispose()
    $trimmed = $tighter
  }
}

$square = To-Square $trimmed 0
$trimmed.Dispose()

$final = Get-ContentBounds $square 254
if ($null -ne $final -and $final.Width -gt 8 -and $final.Height -gt 8) {
  $tighter = Copy-Region $square $final
  $square.Dispose()
  $square = To-Square $tighter 0
  $tighter.Dispose()
}

Save-Icon $square (Join-Path $assets "favicon.png") 32
Save-Icon $square (Join-Path $assets "apple-touch-icon.png") 180
Save-Icon $square (Join-Path $assets "favicon-512.png") 512
$square.Dispose()

Write-Host "Wrote favicon.png, apple-touch-icon.png, favicon-512.png"
