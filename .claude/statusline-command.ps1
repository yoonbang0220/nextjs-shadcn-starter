$input_data = $input | Out-String
try { $json = $input_data | ConvertFrom-Json } catch { exit 0 }

$ESC  = [char]27
$BOLD = "$ESC[1m"
$CYAN = "$ESC[36m"
$YEL  = "$ESC[33m"
$RST  = "$ESC[0m"

$model = if ($json.model.display_name) { $json.model.display_name } else { "Unknown" }
$used_pct = $json.context_window.used_percentage
$usage = $json.context_window.current_usage

$inp = if ($usage.input_tokens) { [double]$usage.input_tokens } else { 0 }
$out_t = if ($usage.output_tokens) { [double]$usage.output_tokens } else { 0 }
$cw  = if ($usage.cache_creation_input_tokens) { [double]$usage.cache_creation_input_tokens } else { 0 }
$cr  = if ($usage.cache_read_input_tokens) { [double]$usage.cache_read_input_tokens } else { 0 }

$result = "${BOLD}${model}${RST}"

if ($used_pct) {
    $pct = [math]::Round($used_pct)
    $result += " ${CYAN}CTX:${pct}%${RST}"
}

if ($inp -gt 0) {
    $cost = ($inp * 3.00 + $out_t * 15.00 + $cw * 3.75 + $cr * 0.30) / 1000000
    $cost_str = '$' + ("{0:F4}" -f $cost)
    $result += " ${YEL}${cost_str}${RST}"
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::Write($result)
