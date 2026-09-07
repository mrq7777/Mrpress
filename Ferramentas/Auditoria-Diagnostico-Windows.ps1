#Requires -RunAsAdministrator
<#
============================================================================
 AUDITORIA COMPLETA DE DIAGNOSTICO - WINDOWS / HARDWARE / REDE / PERFORMANCE
 MODO SOMENTE DIAGNOSTICO - NENHUM COMANDO DE ESCRITA/ALTERACAO E EXECUTADO
============================================================================
 Como usar:
 1. Clique com o botao direito no arquivo > "Executar com PowerShell"
    (ou abra o PowerShell como Administrador e rode:
     powershell -ExecutionPolicy Bypass -File .\Auditoria-Diagnostico-Windows.ps1)
 2. Aguarde a conclusao (pode levar de 3 a 10 minutos).
 3. Um arquivo .txt sera criado na area de trabalho com o relatorio completo.
 4. Envie esse arquivo .txt de volta para o Claude para analise.

 Este script NAO desinstala, apaga, altera registro/servicos/drivers/rede/
 BIOS, finaliza processos, desativa itens de inicializacao nem executa
 comandos de reparo (SFC/DISM/CHKDSK). Apenas LE e CONSULTA informacoes.
============================================================================
#>

$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'

$desktop = [Environment]::GetFolderPath("Desktop")
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$reportPath = Join-Path $desktop "Auditoria_PC_$timestamp.txt"

function Write-Section {
    param([string]$Title)
    "`r`n" + ("=" * 90) + "`r`n$Title`r`n" + ("=" * 90) | Out-File -FilePath $reportPath -Append -Encoding UTF8
}

function Write-Sub {
    param([string]$Title)
    "`r`n--- $Title ---" | Out-File -FilePath $reportPath -Append -Encoding UTF8
}

function Run-Safe {
    param([string]$Label, [scriptblock]$Block)
    Write-Sub $Label
    try {
        $result = & $Block
        if ($null -eq $result -or $result -eq "") {
            "  (sem dados retornados ou nao aplicavel neste sistema)" | Out-File -FilePath $reportPath -Append -Encoding UTF8
        } else {
            $result | Out-String -Width 200 | Out-File -FilePath $reportPath -Append -Encoding UTF8
        }
    } catch {
        "  [ERRO ao coletar] $($_.Exception.Message)" | Out-File -FilePath $reportPath -Append -Encoding UTF8
    }
}

"AUDITORIA COMPLETA DE DIAGNOSTICO - MODO SOMENTE LEITURA" | Out-File -FilePath $reportPath -Encoding UTF8
"Gerado em: $(Get-Date)" | Out-File -FilePath $reportPath -Append -Encoding UTF8
"Computador: $env:COMPUTERNAME | Usuario: $env:USERNAME" | Out-File -FilePath $reportPath -Append -Encoding UTF8

# ============================================================
# 1. IDENTIFICACAO DO COMPUTADOR
# ============================================================
Write-Section "1. IDENTIFICACAO DO COMPUTADOR"

Run-Safe "Versao e Build do Windows" {
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, InstallDate, LastBootUpTime
}
Run-Safe "UBR / Build detalhado (Registro)" {
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" |
        Select-Object ProductName, DisplayVersion, ReleaseId, CurrentBuild, UBR, EditionID
}
Run-Safe "Fabricante e Modelo" {
    Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, SystemFamily, SystemType, TotalPhysicalMemory
}
Run-Safe "Placa-mae" {
    Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product, Version, SerialNumber
}
Run-Safe "BIOS / UEFI" {
    Get-CimInstance Win32_BIOS | Select-Object Manufacturer, Name, SMBIOSBIOSVersion, ReleaseDate, SerialNumber
}
Run-Safe "Modo de firmware (BIOS Legacy ou UEFI)" {
    $fw = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "PEFirmwareType" -ErrorAction SilentlyContinue).PEFirmwareType
    if ($fw -eq 1) { "Legacy BIOS" } elseif ($fw -eq 2) { "UEFI" } else { "Nao identificado" }
}
Run-Safe "Processador" {
    Get-CimInstance Win32_Processor | Select-Object Name, Manufacturer, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, CurrentClockSpeed, L2CacheSize, L3CacheSize, Status, LoadPercentage
}
Run-Safe "Memoria RAM - Modulos fisicos" {
    Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, DeviceLocator, Manufacturer, PartNumber, @{N='CapacidadeGB';E={[math]::Round($_.Capacity/1GB,2)}}, Speed, ConfiguredClockSpeed, MemoryType, FormFactor, SerialNumber
}
Run-Safe "Memoria RAM - Total e slots" {
    Get-CimInstance Win32_PhysicalMemoryArray | Select-Object MemoryDevices, MaxCapacity, @{N='MaxCapacidadeGB';E={[math]::Round($_.MaxCapacity/1MB,2)}}
}
Run-Safe "GPU" {
    Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, DriverDate, @{N='VRAM_MB';E={[math]::Round($_.AdapterRAM/1MB,0)}}, CurrentHorizontalResolution, CurrentVerticalResolution, Status
}
Run-Safe "Discos fisicos" {
    Get-PhysicalDisk | Select-Object DeviceId, FriendlyName, MediaType, BusType, Size, HealthStatus, OperationalStatus
}
Run-Safe "Discos fisicos (detalhe WMI)" {
    Get-CimInstance Win32_DiskDrive | Select-Object DeviceID, Model, InterfaceType, MediaType, @{N='TamanhoGB';E={[math]::Round($_.Size/1GB,2)}}, SerialNumber, Status
}
Run-Safe "Particoes e Volumes" {
    Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem, DriveType, HealthStatus, @{N='TamanhoGB';E={[math]::Round($_.Size/1GB,2)}}, @{N='LivreGB';E={[math]::Round($_.SizeRemaining/1GB,2)}}
}
Run-Safe "Interfaces de rede" {
    Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed, MediaType
}
Run-Safe "Dispositivos USB conectados" {
    Get-CimInstance Win32_USBControllerDevice | ForEach-Object {
        [wmi]($_.Dependent)
    } | Select-Object Name, Description, DeviceID -Unique
}

# ============================================================
# 2. HARDWARE - SAUDE GERAL / EVENTOS WHEA
# ============================================================
Write-Section "2. HARDWARE - SAUDE E EVENTOS DE ERRO"

Run-Safe "Eventos WHEA-Logger (erros de hardware - ultimos 90 dias)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WHEA-Logger'; StartTime=(Get-Date).AddDays(-90)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, LevelDisplayName, Message -First 50
}
Run-Safe "Eventos Kernel-Power (desligamentos inesperados/quedas - ultimos 90 dias)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Kernel-Power'; Id=41,6008; StartTime=(Get-Date).AddDays(-90)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, LevelDisplayName, Message -First 50
}
Run-Safe "Eventos criticos gerais do log System (ultimos 30 dias)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, @{N='Msg';E={$_.Message.Substring(0,[Math]::Min(150,$_.Message.Length))}} -First 100
}
Run-Safe "Dispositivos com erro no Gerenciador de Dispositivos (Status != OK)" {
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 } |
        Select-Object Name, DeviceID, ConfigManagerErrorCode, Status
}
Run-Safe "Status de temperatura (sensor termico ACPI, se disponivel)" {
    Get-CimInstance -Namespace "root/wmi" -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue |
        Select-Object InstanceName, @{N='TempCelsius';E={[math]::Round(($_.CurrentTemperature/10)-273.15,1)}}
}

# ============================================================
# 3. SSD / HD / NVMe
# ============================================================
Write-Section "3. SAUDE DE ARMAZENAMENTO (SSD/HD/NVMe)"

Run-Safe "Status de confiabilidade e SMART (Get-StorageReliabilityCounter)" {
    Get-PhysicalDisk | ForEach-Object {
        $disk = $_
        $rel = $disk | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            Disco               = $disk.FriendlyName
            HealthStatus        = $disk.HealthStatus
            OperationalStatus   = $disk.OperationalStatus
            Wear                = $rel.Wear
            Temperature_C       = $rel.Temperature
            ReadErrorsTotal     = $rel.ReadErrorsTotal
            WriteErrorsTotal    = $rel.WriteErrorsTotal
            PowerOnHours        = $rel.PowerOnHours
            StartStopCycles     = $rel.StartStopCycles
        }
    }
}
Run-Safe "Status SMART basico (Win32_DiskDrive predictive failure)" {
    Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue |
        Select-Object InstanceName, PredictFailure, Reason
}
Run-Safe "Espaco livre por unidade" {
    Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter, @{N='TamanhoGB';E={[math]::Round($_.Size/1GB,2)}}, @{N='LivreGB';E={[math]::Round($_.SizeRemaining/1GB,2)}}, @{N='%Livre';E={[math]::Round(($_.SizeRemaining/$_.Size)*100,1)}}
}
Run-Safe "Erros de sistema de arquivos registrados (NTFS/Ntfs - ultimos 90 dias)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Ntfs'; StartTime=(Get-Date).AddDays(-90)} -ErrorAction SilentlyContinue |
        Where-Object { $_.LevelDisplayName -in @('Error','Warning','Critical') } |
        Select-Object TimeCreated, Id, LevelDisplayName, Message -First 50
}
Run-Safe "Eventos de disco (Disk - ultimos 90 dias)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='disk'; StartTime=(Get-Date).AddDays(-90)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, LevelDisplayName, Message -First 50
}
Run-Safe "Eventos storahci/stornvme (ultimos 90 dias)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='storahci','stornvme'; StartTime=(Get-Date).AddDays(-90)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message -First 50
}
Run-Safe "Ultima data de CHKDSK / verificacao de volume (dirty bit)" {
    Get-Volume | ForEach-Object {
        if ($_.DriveLetter) {
            $dl = $_.DriveLetter
            $out = fsutil dirty query "${dl}:" 2>$null
            [PSCustomObject]@{ Drive = "${dl}:"; DirtyBitInfo = $out }
        }
    }
}

# ============================================================
# 4. MEMORIA RAM
# ============================================================
Write-Section "4. MEMORIA RAM"

Run-Safe "RAM instalada x utilizavel x em uso" {
    $os = Get-CimInstance Win32_OperatingSystem
    [PSCustomObject]@{
        RAM_Total_GB     = [math]::Round($os.TotalVisibleMemorySize/1MB,2)
        RAM_Livre_GB     = [math]::Round($os.FreePhysicalMemory/1MB,2)
        RAM_EmUso_GB     = [math]::Round(($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/1MB,2)
        '%EmUso'         = [math]::Round((($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/$os.TotalVisibleMemorySize)*100,1)
    }
}
Run-Safe "Memoria virtual / arquivo de paginacao" {
    Get-CimInstance Win32_PageFileUsage | Select-Object Name, @{N='TamanhoAlocadoMB';E={$_.AllocatedBaseSize}}, @{N='UsoAtualMB';E={$_.CurrentUsage}}, @{N='PicoUsoMB';E={$_.PeakUsage}}
}
Run-Safe "Configuracao do pagefile" {
    Get-CimInstance Win32_PageFileSetting | Select-Object Name, InitialSize, MaximumSize
}
Run-Safe "Top 15 processos por uso de memoria (working set)" {
    Get-Process | Sort-Object WS -Descending | Select-Object -First 15 Name, Id, @{N='RAM_MB';E={[math]::Round($_.WS/1MB,1)}}, @{N='CPU_s';E={$_.CPU}}
}
Run-Safe "Eventos de erro de memoria (MemoryDiagnostics-Results, ultimos 180 dias)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-MemoryDiagnostics-Results'; StartTime=(Get-Date).AddDays(-180)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
}

# ============================================================
# 5. CPU E PERFORMANCE
# ============================================================
Write-Section "5. CPU E PERFORMANCE"

Run-Safe "Uso atual de CPU (total)" {
    Get-CimInstance Win32_Processor | Select-Object Name, LoadPercentage
}
Run-Safe "Top 15 processos por uso de CPU (amostra de 3s)" {
    Get-Counter '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty CounterSamples |
        Where-Object { $_.InstanceName -notin @('_total','idle') } |
        Sort-Object CookedValue -Descending | Select-Object -First 15 InstanceName, @{N='CPU_%';E={[math]::Round($_.CookedValue / [Environment]::ProcessorCount,1)}}
}
Run-Safe "Contadores de sistema (fila de processador, disco)" {
    Get-Counter '\System\Processor Queue Length','\PhysicalDisk(_Total)\% Disk Time' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty CounterSamples | Select-Object Path, CookedValue
}
Run-Safe "Servicos em execucao com maior consumo (Top 10 por handles/threads)" {
    Get-Process | Sort-Object Handles -Descending | Select-Object -First 10 Name, Id, Handles, Threads, @{N='RAM_MB';E={[math]::Round($_.WS/1MB,1)}}
}

# ============================================================
# 6. INICIALIZACAO DO WINDOWS
# ============================================================
Write-Section "6. PROGRAMAS E SERVICOS DE INICIALIZACAO"

Run-Safe "Itens de inicializacao (Get-CimInstance Win32_StartupCommand)" {
    Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User
}
Run-Safe "Itens de inicializacao (Registro Run/RunOnce - HKLM)" {
    Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
}
Run-Safe "Itens de inicializacao (Registro Run/RunOnce - HKCU)" {
    Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
}
Run-Safe "Tarefas agendadas ativas (nao-Microsoft)" {
    Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' -and $_.TaskPath -notlike '\Microsoft\*' } |
        Select-Object TaskName, TaskPath, State
}
Run-Safe "Tarefas agendadas Microsoft habilitadas (resumo, para referencia)" {
    (Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' -and $_.TaskPath -like '\Microsoft\*' }).Count
}
Run-Safe "Impacto de inicializacao (se disponivel via WMI)" {
    Get-CimInstance -Namespace root\cimv2 -ClassName Win32_StartupCommand -ErrorAction SilentlyContinue | Select-Object Name, Location
}

# ============================================================
# 7. SERVICOS DO WINDOWS
# ============================================================
Write-Section "7. SERVICOS"

Run-Safe "Servicos configurados para 'Automatico' mas PARADOS (possivel falha)" {
    Get-CimInstance Win32_Service | Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } |
        Select-Object Name, DisplayName, State, StartMode, PathName
}
Run-Safe "Todos os servicos em execucao (resumo)" {
    Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName, StartType | Sort-Object DisplayName
}
Run-Safe "Servicos de terceiros (nao Microsoft) instalados" {
    Get-CimInstance Win32_Service | Where-Object { $_.PathName -notmatch 'Windows\\System32' } |
        Select-Object Name, DisplayName, State, StartMode, PathName
}

# ============================================================
# 8. LOGS DO WINDOWS
# ============================================================
Write-Section "8. LOGS DO WINDOWS (EVENTOS CRITICOS E DE ERRO)"

Run-Safe "System - Critical/Error (ultimos 15 dias, top 80)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddDays(-15)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, LevelDisplayName -First 80
}
Run-Safe "Application - Critical/Error (ultimos 15 dias, top 80)" {
    Get-WinEvent -FilterHashtable @{LogName='Application'; Level=1,2; StartTime=(Get-Date).AddDays(-15)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, LevelDisplayName -First 80
}
Run-Safe "Falhas de aplicativos (Application Error - Id 1000)" {
    Get-WinEvent -FilterHashtable @{LogName='Application'; ProviderName='Application Error'; StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, Message -First 40
}
Run-Safe "Historico de desligamentos/reinicializacoes (Id 1074, 6006, 6008, 6005, 41)" {
    Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074,6006,6008,6005,41; StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, Message -First 60
}
Run-Safe "Contagem de erros por provedor (System, ultimos 30 dias) - visao geral" {
    Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue |
        Group-Object ProviderName | Sort-Object Count -Descending | Select-Object Count, Name
}

# ============================================================
# 9. DRIVERS
# ============================================================
Write-Section "9. DRIVERS"

Run-Safe "Drivers instalados (assinados/nao assinados, data)" {
    Get-CimInstance Win32_PnPSignedDriver | Select-Object DeviceName, DriverVersion, DriverDate, Manufacturer, IsSigned |
        Sort-Object DriverDate
}
Run-Safe "Dispositivos desconhecidos ou com problema" {
    Get-CimInstance Win32_PnPEntity | Where-Object { $_.Status -ne 'OK' -or $_.Name -match 'Unknown' } |
        Select-Object Name, DeviceID, Status, ConfigManagerErrorCode
}
Run-Safe "Drivers mais antigos que 3 anos (possivel desatualizacao)" {
    $limite = (Get-Date).AddYears(-3)
    Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DriverDate -and ([datetime]$_.DriverDate -lt $limite) } |
        Select-Object DeviceName, DriverVersion, DriverDate, Manufacturer | Sort-Object DriverDate
}

# ============================================================
# 10. REDE
# ============================================================
Write-Section "10. REDE"

Run-Safe "Configuracao IP completa" {
    Get-NetIPConfiguration | Select-Object InterfaceAlias, InterfaceDescription, IPv4Address, IPv4DefaultGateway, DNSServer
}
Run-Safe "Velocidade negociada dos adaptadores" {
    Get-NetAdapter | Select-Object Name, Status, LinkSpeed, MediaType, MacAddress
}
Run-Safe "Servidores DNS configurados" {
    Get-DnsClientServerAddress | Where-Object { $_.AddressFamily -eq 2 } | Select-Object InterfaceAlias, ServerAddresses
}
Run-Safe "Tabela de rotas" {
    Get-NetRoute -AddressFamily IPv4 | Where-Object { $_.NextHop -ne '0.0.0.0' -or $_.DestinationPrefix -eq '0.0.0.0/0' } |
        Select-Object DestinationPrefix, NextHop, RouteMetric, InterfaceAlias
}
Run-Safe "Teste de latencia - Gateway padrao" {
    $gw = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway }).IPv4DefaultGateway.NextHop | Select-Object -First 1
    if ($gw) { Test-Connection -ComputerName $gw -Count 4 | Select-Object Address, ResponseTime } else { "Gateway nao encontrado" }
}
Run-Safe "Teste de latencia - Internet (8.8.8.8)" {
    Test-Connection -ComputerName 8.8.8.8 -Count 4 | Select-Object Address, ResponseTime
}
Run-Safe "Teste de resolucao DNS (google.com)" {
    Resolve-DnsName google.com -ErrorAction SilentlyContinue | Select-Object Name, IPAddress, Type
}
Run-Safe "Conexoes TCP estabelecidas (com processo)" {
    Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | ForEach-Object {
        $proc = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
        [PSCustomObject]@{ Local="$($_.LocalAddress):$($_.LocalPort)"; Remoto="$($_.RemoteAddress):$($_.RemotePort)"; Processo=$proc; PID=$_.OwningProcess }
    } | Select-Object -First 60
}
Run-Safe "Portas em escuta (Listening)" {
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | ForEach-Object {
        $proc = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
        [PSCustomObject]@{ Porta=$_.LocalPort; Endereco=$_.LocalAddress; Processo=$proc; PID=$_.OwningProcess }
    } | Sort-Object Porta -Unique
}
Run-Safe "Estatisticas de erros de rede por adaptador" {
    Get-NetAdapterStatistics | Select-Object Name, ReceivedPackets, ReceivedDiscardedPackets, ReceivedPacketErrors, OutboundPacketErrors
}

# ============================================================
# 11. SEGURANCA (INSPECAO BASICA)
# ============================================================
Write-Section "11. SEGURANCA - INSPECAO BASICA"

Run-Safe "Status Windows Defender / Antivirus" {
    Get-MpComputerStatus -ErrorAction SilentlyContinue | Select-Object AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled, AntivirusSignatureLastUpdated, QuickScanAge, FullScanAge
}
Run-Safe "Firewall - perfis e status" {
    Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
}
Run-Safe "Processos sem assinatura digital ou de localizacao incomum (Temp, AppData\Local\Temp)" {
    Get-Process | Where-Object { $_.Path -and ($_.Path -match '\\Temp\\' -or $_.Path -match '\\AppData\\Local\\Temp\\') } |
        Select-Object Name, Id, Path
}
Run-Safe "Tarefas agendadas com acao suspeita (powershell/cmd/mshta/wscript apontando p/ Temp ou AppData)" {
    Get-ScheduledTask | ForEach-Object {
        $actions = $_.Actions
        foreach ($a in $actions) {
            if ($a.Execute -match 'powershell|cmd|mshta|wscript|cscript' -and ($a.Arguments -match 'Temp|AppData' -or $a.Execute -match 'Temp|AppData')) {
                [PSCustomObject]@{ Tarefa=$_.TaskName; Caminho=$_.TaskPath; Executavel=$a.Execute; Argumentos=$a.Arguments }
            }
        }
    }
}
Run-Safe "Contas de usuario locais" {
    Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordRequired
}
Run-Safe "Membros do grupo Administradores" {
    Get-LocalGroupMember -Group "Administradores" -ErrorAction SilentlyContinue
    if (-not $?) { Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue }
}
Run-Safe "Conexoes de rede para IPs externos incomuns (fora da rede local, portas altas)" {
    Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
        Where-Object { $_.RemoteAddress -notmatch '^(127\.|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)' } |
        ForEach-Object {
            $proc = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
            [PSCustomObject]@{ Remoto="$($_.RemoteAddress):$($_.RemotePort)"; Processo=$proc; PID=$_.OwningProcess }
        } | Select-Object -First 40
}

# ============================================================
# 12. INTEGRIDADE DO WINDOWS (SOMENTE VERIFICACAO)
# ============================================================
Write-Section "12. INTEGRIDADE DO WINDOWS (INDICADORES - SEM REPARO)"

Run-Safe "Ultimo resultado de verificacao SFC (CBS.log - ultimas linhas relevantes, se existir)" {
    $cbs = "$env:windir\Logs\CBS\CBS.log"
    if (Test-Path $cbs) {
        Select-String -Path $cbs -Pattern "SFC|corrupt|cannot repair" -SimpleMatch:$false -ErrorAction SilentlyContinue |
            Select-Object -Last 30 | ForEach-Object { $_.Line }
    } else { "CBS.log nao encontrado" }
}
Run-Safe "Status do componente de servicos (Trusted Installer, WU)" {
    Get-Service -Name TrustedInstaller, wuauserv, bits -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType
}
Run-Safe "Espaco livre no disco do sistema (C:)" {
    Get-Volume -DriveLetter C -ErrorAction SilentlyContinue | Select-Object DriveLetter, @{N='TamanhoGB';E={[math]::Round($_.Size/1GB,2)}}, @{N='LivreGB';E={[math]::Round($_.SizeRemaining/1GB,2)}}
}
Run-Safe "Ultima instalacao de atualizacoes do Windows" {
    Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 HotFixID, Description, InstalledOn
}
Run-Safe "Uptime do sistema desde o ultimo boot" {
    $os = Get-CimInstance Win32_OperatingSystem
    [PSCustomObject]@{ UltimoBoot=$os.LastBootUpTime; UptimeDias=[math]::Round(((Get-Date)-$os.LastBootUpTime).TotalDays,2) }
}

# ============================================================
# 13. PROGRAMAS INSTALADOS
# ============================================================
Write-Section "13. PROGRAMAS INSTALADOS"

Run-Safe "Lista completa de programas instalados (Registro, 64+32 bits)" {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    Get-ItemProperty $paths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
        Sort-Object DisplayName -Unique
}

# ============================================================
# FIM
# ============================================================
Write-Section "COLETA FINALIZADA"
"Relatorio gerado com sucesso em: $reportPath" | Out-File -FilePath $reportPath -Append -Encoding UTF8
"Nenhuma alteracao foi feita no sistema. Este script e somente leitura." | Out-File -FilePath $reportPath -Append -Encoding UTF8

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host " AUDITORIA CONCLUIDA" -ForegroundColor Green
Write-Host " Relatorio salvo em: $reportPath" -ForegroundColor Green
Write-Host " Envie este arquivo .txt de volta para o Claude para analise." -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green
