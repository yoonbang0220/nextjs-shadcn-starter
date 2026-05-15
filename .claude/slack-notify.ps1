param(
    [string]$type = "unknown"
)

$webhookUrl = $env:SLACK_WEBHOOK_URL
if (-not $webhookUrl) { exit 0 }

try {
    $rawInput = [Console]::In.ReadToEnd()
    $json = $rawInput | ConvertFrom-Json
} catch {
    $json = $null
}

$kst = (Get-Date).ToUniversalTime().AddHours(9)
$timeStr = $kst.ToString("HH:mm")

$message = switch ($type) {
    "permission" {
        $toolName = if ($json.tool_name) { [string]$json.tool_name } else { "Unknown" }
        $detail = ""
        if ($json.tool_input) {
            if ($json.tool_input.command) {
                $cmd = [string]$json.tool_input.command
                $detail = if ($cmd.Length -gt 60) { $cmd.Substring(0, 60) + "..." } else { $cmd }
            } elseif ($json.tool_input.file_path) { $detail = [string]$json.tool_input.file_path }
            elseif ($json.tool_input.path)        { $detail = [string]$json.tool_input.path }
            elseif ($json.tool_input.query)       { $detail = [string]$json.tool_input.query }
        }
        if ($detail) { ":lock: *권한 요청* [$timeStr]`n*도구:* $toolName`n*내용:* $detail" }
        else         { ":lock: *권한 요청* [$timeStr]`n*도구:* $toolName" }
    }
    "stop" {
        ":white_check_mark: *작업 완료!* [$timeStr]"
    }
    default {
        ":robot_face: Claude Code 이벤트 [$timeStr]: $type"
    }
}

try {
    $body = @{ text = $message } | ConvertTo-Json -Compress

    # PowerShell HTTP 클라이언트의 인코딩 재처리 문제 완전 우회
    # UTF-8 NoBOM으로 임시 파일에 저장 → curl.exe로 바이트 그대로 전송
    $tempFile = [System.IO.Path]::Combine($env:TEMP, "slack-hook-$(Get-Random).json")
    [System.IO.File]::WriteAllText($tempFile, $body, (New-Object System.Text.UTF8Encoding($false)))
    curl.exe -s -X POST -H "Content-Type: application/json" -d "@$tempFile" $webhookUrl | Out-Null
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
} catch {}

exit 0
