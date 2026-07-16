$files = @('terms.jsp','privacy.jsp','policy-cancel.jsp','help.jsp','guide-booking.jsp','contact.jsp')
foreach ($f in $files) {
    $p = "src\frontend\views\static\$f"
    if (Test-Path $p) {
        $c = Get-Content $p -Raw
        # BOM + pageEncoding line in HEAD; main side empty
        $pattern = "<<<<<<< HEAD`r?`n\xEF\xBB\xBF?<%@ page pageEncoding=`"UTF-8`" contentType=`"text/html; charset=UTF-8`" language=`"java`" %>`r?`n`r?`n=======`r?`n>>>>>>> origin/main`r?`n"
        $replacement = '<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>' + [Environment]::NewLine
        $c = [regex]::Replace($c, $pattern, $replacement)
        Set-Content -Path $p -Value $c -NoNewline
        Write-Host "Processed $f"
    }
}
