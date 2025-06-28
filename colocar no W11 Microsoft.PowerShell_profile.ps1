# Estilo de previsão de comandos
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -Colors @{ InlinePrediction = 'DarkGray' }

# Ícones bonitos no terminal (requer módulo Terminal-Icons)
Import-Module -Name Terminal-Icons

function TemaPosh {
    $themesPath = "C:\Users\SeuNome\AppData\Local\Programs\oh-my-posh\themes"
    $themes = Get-ChildItem -Path $themesPath -Filter *.omp.json | Select-Object -ExpandProperty Name

    if (-not $themes) {
        Write-Host "Nenhum tema encontrado em $themesPath" -ForegroundColor Red
        return
    }

    Write-Host "Temas Oh My Posh disponíveis:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $themes.Count; $i++) {
        Write-Host ("[{0}] {1}" -f ($i + 1), $themes[$i])
    }

    do {
        $selection = Read-Host "Digite o número do tema que quer aplicar (ou 's' para sair)"
        if ($selection -eq 's') {
            Write-Host "Saindo sem aplicar tema." -ForegroundColor Yellow
            return
        }
    } while (-not ($selection -match '^\d+$') -or [int]$selection -lt 1 -or [int]$selection -gt $themes.Count)

    $chosenTheme = $themes[[int]$selection - 1]
    $chosenThemePath = Join-Path $themesPath $chosenTheme

    Write-Host "Aplicando tema $chosenTheme..." -ForegroundColor Green
    # APLICA O TEMA TEMPORARIAMENTE - CORREÇÃO AQUI
    oh-my-posh init pwsh --config "$chosenThemePath" | Invoke-Expression

    $save = Read-Host "Quer salvar esse tema no perfil para carregar sempre? (s/n)"
    if ($save -eq 's') {
        SalvarTemaNoPerfil -ThemePath $chosenThemePath
        Write-Host "Tema salvo no perfil! Reinicie o PowerShell para aplicar." -ForegroundColor Green
    } else {
        Write-Host "Tema aplicado temporariamente." -ForegroundColor Yellow
    }
}

function SalvarTemaNoPerfil {
    param([string]$ThemePath)

    $profilePath = $PROFILE
    # CORREÇÃO DA LINHA DO COMANDO OH-MY-POSH: adicionado `| Invoke-Expression`
    $ohMyPoshCommand = "oh-my-posh init pwsh --config `"$ThemePath`" | Invoke-Expression"

    # Lê o conteúdo existente do perfil, se houver
    $existingContent = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { "" }

    # Remove quaisquer linhas anteriores de oh-my-posh init para evitar duplicatas ou conflitos
    # Esta regex procura por linhas que começam com 'oh-my-posh init pwsh'
    $cleanedContent = $existingContent -replace '(?m)^oh-my-posh init pwsh.*$', ''

    # Anexa o novo comando oh-my-posh, garantindo que esteja em uma nova linha
    # Trim para evitar linhas em branco extras se o conteúdo substituído estivesse no final
    $newContent = ($cleanedContent.Trim() + "`n" + $ohMyPoshCommand).Trim()

    try {
        Set-Content -Path $profilePath -Value $newContent -Encoding UTF8 -Force
        Write-Host "Tema salvo no perfil em '$profilePath'." -ForegroundColor Green
    }
    catch {
        Write-Host "Erro ao salvar o tema no perfil: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Configuração inicial do Oh My Posh (deve ser executada quando o perfil carrega)
# CORREÇÃO AQUI: adicionado `| Invoke-Expression`
oh-my-posh init pwsh --config "C:\Users\SeuNome\AppData\Local\Programs\oh-my-posh\themes\montys.omp.json" | Invoke-Expression
