# Limpa a tela ao iniciar
Clear-Host

# Importa o módulo Terminal-Icons para exibir ícones em listagens de arquivos.
# Certifique-se de que este módulo está instalado no seu PowerShell do WSL.
# Para instalar: Install-Module -Name Terminal-Icons -Scope CurrentUser
Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

# Configura o PSReadLine para exibir sugestões de comandos em estilo de lista.
# Isso proporciona uma experiência de autocompletar mais rica.
# O módulo PSReadLine é geralmente carregado por padrão ou com o PowerShell.
Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue

# Define o alias 'ls' para 'Get-ChildItem' explicitamente.
# Isso garante que o comando 'ls' funcione como esperado com ícones,
# caso o alias padrão não esteja a ser carregado.
Set-Alias ls Get-ChildItem -ErrorAction SilentlyContinue

# Verifica se o tema do Oh My Posh já foi carregado para evitar reexecução em subshells
if (-not $global:ThemeLoaded) {
    # Define o caminho para o perfil do PowerShell do Windows 11
    # Este caminho acessa o disco C: do Windows a partir do ambiente Linux do WSL
    $profileWindowsPath = "/mnt/c/Users/SeuNome/OneDrive/Documentos/PowerShell/Microsoft.PowerShell_profile.ps1"

    # Verifica se o arquivo de perfil do Windows existe
    if (Test-Path $profileWindowsPath) {
        # Lê o conteúdo completo do perfil do Windows para análise
        $profileContent = Get-Content $profileWindowsPath -Raw

        # Expressão regular para encontrar a linha de configuração do Oh My Posh
        # Procura por '--config' seguido de aspas simples ou duplas, capturando o caminho do tema.
        # Usa 'RightToLeft' para garantir que a última configuração explícita do tema seja pega.
        $regexPattern = 'oh-my-posh init pwsh --config\s+["''](?<path>[A-Z]:\\(?:[^\\/]+\\)*[^\\/]+\.omp\.json)["'']'
        $matches = [regex]::Matches($profileContent, $regexPattern, [System.Text.RegularExpressions.RegexOptions]::RightToLeft)

        $themeLine = $null
        if ($matches.Count -gt 0) {
            # Se uma correspondência for encontrada, extrai o caminho e normaliza as barras.
            $lastMatch = $matches[0]
            $themeLine = ($lastMatch.Groups['path'].Value -replace '\\', '/').Trim()
        }

        # Converte o caminho do Windows (ex: "C:/...") para o formato de caminho do WSL (Linux)
        # Ex: "C:/Program Files/..." se torna "/mnt/c/Program Files/..."
        if ($themeLine) {
            # Extrai a letra da unidade e o restante do caminho usando regex para robustez
            if ($themeLine -match '^(?<drive>[A-Za-z]):/(?<path>.*)') {
                $driveLetter = $matches['drive']
                $relativePath = $matches['path']

                # Constrói o caminho completo no formato WSL
                $wslThemePath = "/mnt/" + $driveLetter.ToLowerInvariant() + "/" + $relativePath

                # Verifica se o arquivo do tema existe no caminho do WSL antes de carregá-lo
                if (Test-Path $wslThemePath) {
                    # Inicializa o Oh My Posh para PowerShell no WSL com o tema encontrado
                    oh-my-posh init pwsh --config "$wslThemePath" | Invoke-Expression
                    $global:ThemeLoaded = $true # Marca que o tema foi carregado com sucesso
                } else {
                    Write-Warning "Tema Oh My Posh não encontrado no WSL: '$wslThemePath'. Verifique o caminho."
                }
            } else {
                Write-Warning "Não foi possível analisar o caminho do tema Windows: '$themeLine'. Formato inesperado."
            }
        } else {
            Write-Warning "Não foi possível extrair o caminho do tema Oh My Posh do perfil do Windows. Verifique a configuração no Windows."
        }
    } else {
        Write-Warning "Perfil do PowerShell do Windows 11 não encontrado em: $profileWindowsPath. Verifique se o caminho está correto."
    }
}
