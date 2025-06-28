# Documentação: Sincronização do Tema Oh My Posh entre Windows e WSL PowerShell

Este documento descreve a solução implementada para garantir que o tema do Oh My Posh configurado no PowerShell do Windows 11 seja automaticamente carregado e exibido corretamente no PowerShell que é executado dentro do ambiente WSL (Windows Subsystem for Linux).

## 1. O Problema

Originalmente, o usuário configurava seu tema Oh My Posh no PowerShell do Windows 11 através do arquivo `Microsoft.PowerShell_profile.ps1`. No entanto, ao iniciar uma sessão do PowerShell dentro do WSL (`pwsh`), o tema não era carregado da mesma forma, resultando em um prompt padrão ou com formatação incorreta.

A causa principal era que o perfil do PowerShell no WSL estava tentando referenciar o arquivo de tema do Windows usando um caminho no formato Windows (`C:\...`), que não é diretamente compreendido pelo ambiente Linux do WSL. Mesmo com a substituição de barras (`\`) por (`/`), o prefixo de unidade (`C:/`) precisava ser traduzido para o formato de montagem do WSL (`/mnt/c/`).

## 2. A Solução

A solução envolveu a modificação do arquivo de perfil do PowerShell no WSL (`~/.config/powershell/Microsoft.PowerShell_profile.ps1` ou o caminho retornado por `$PROFILE` dentro do WSL). O script neste perfil foi aprimorado para:

- Localizar o arquivo `Microsoft.PowerShell_profile.ps1` do Windows 11 dentro do WSL.
- Extrair o caminho do tema do Oh My Posh configurado nesse arquivo.
- Converter o caminho do Windows (`C:\...`) para um caminho compatível com o sistema de arquivos do WSL (`/mnt/c/...`).
- Inicializar o Oh My Posh no PowerShell do WSL usando o caminho do tema convertido.

## 3. Detalhes da Implementação

O código-fonte da solução está contido no arquivo `Microsoft.PowerShell_profile.ps1` localizado no ambiente WSL.

### 3.1. Código (`Microsoft.PowerShell_profile.ps1` no WSL)



### 3.2. Como Funciona

- **Localização do Perfil Windows**: A variável `$profileWindowsPath` aponta para o perfil do PowerShell no Windows, acessível via `/mnt/c/`.
- **Leitura e Extração do Tema**:
  - O conteúdo é lido com `Get-Content -Raw`.
  - Uma regex busca a última linha com `oh-my-posh init pwsh`.
  - O caminho é extraído e convertido de `C:\...` para `C:/...`.
- **Conversão para Caminho WSL**:
  - A letra da unidade (ex: `C`) é extraída e transformada em minúscula.
  - O caminho é reconstruído no formato `/mnt/c/...`.
- **Inicialização**:
  - O comando `oh-my-posh init pwsh --config "$wslThemePath"` é executado com `Invoke-Expression`.
- **Prevenção de execução repetida**:
  - Usa-se `$global:ThemeLoaded` para garantir que o tema não seja recarregado em subshells.
- **Tratamento de Erros**:
  - Mensagens com `Write-Warning` são usadas para indicar falhas durante o processo.

## 4. Pré-requisitos

Para que a solução funcione corretamente, você deve ter:

- **Oh My Posh instalado**: Tanto no Windows quanto no WSL.
- **Nerd Font instalada**: Para exibir ícones e glifos corretamente.
- **PowerShell Core (pwsh)**: Instalado nos dois ambientes.

## 5. Como Aplicar/Configurar

1. **Identifique o arquivo de perfil do PowerShell no WSL**  
   Execute no PowerShell dentro do WSL:
   ```powershell
   $PROFILE
   ```

2. **Edite o arquivo**  
   Use um editor de texto como `nano` ou `vim`:
   ```bash
   nano ~/.config/powershell/Microsoft.PowerShell_profile.ps1
   ```

3. **Cole o código**  
   Substitua o conteúdo atual pelo script da seção 3.1.

4. **Salve e saia**  
   No `nano`, use `Ctrl+O`, `Enter` e `Ctrl+X`.

5. **Reinicie o PowerShell no WSL**  
   Feche e abra novamente. O tema será carregado automaticamente.

---

Com essa configuração, o terminal PowerShell no WSL terá a mesma aparência do terminal PowerShell no Windows.
