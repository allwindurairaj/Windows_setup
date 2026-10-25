# Windows Setup

Sets up a Windows development machine in one go using [Chocolatey](https://chocolatey.org/). The script installs Chocolatey, then installs my usual browsers, editors, languages, container and cloud tools, and admin utilities. It can also install WSL (Linux on Windows).

## Requirements

- Windows 10 or 11
- PowerShell, **run as Administrator**
- Internet access
- Plenty of disk space (the full list is roughly 40–50 GB, mostly Visual Studio, Docker, and the IDEs)

## Usage

1. Download or clone this repo:

   ```powershell
   git clone https://github.com/allwindurairaj/Windows_setup.git
   cd Windows_setup
   ```

2. Open PowerShell **as Administrator** and run:

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\setup.ps1
   ```

3. Reboot when it finishes. Docker Desktop, VirtualBox, Sysmon, and WSL need a restart.

### Run it straight from GitHub

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/allwindurairaj/Windows_setup/main/setup.ps1'))
```

### Options

| Parameter | What it does |
|---|---|
| `-Skip <categories>` | Leave out one or more categories |
| `-Only <categories>` | Install only these categories |
| `-IncludeOffice` | Also install Microsoft 365 (64-bit) |
| `-SkipOracle` | Don't install Oracle SQL Developer (otherwise you're prompted for your Oracle login) |
| `-SkipWSL` | Don't install WSL |
| `-LogPath <file>` | Where to save the log (default: `%TEMP%\windows-setup-<timestamp>.log`) |

Categories: `Favorites`, `Terminal`, `CLITools`, `Languages`, `Containers`, `Cloud`, `ApiTools`, `Productivity`, `Monitoring`, `VSCodeExtensions`, `NonEssentials`

```powershell
.\setup.ps1 -Skip NonEssentials,Monitoring              # lean work machine
.\setup.ps1 -Only Terminal,CLITools -SkipOracle -SkipWSL # just the terminal tools
Get-Help .\setup.ps1 -Full                               # built-in help
```

If a package fails, the script keeps going and lists the failures at the end.

## What the script does

1. Installs Chocolatey (skipped if it's already there).
2. Turns on `allowGlobalConfirmation`, so packages install without a prompt for each one.
3. Installs each category below.
4. After **Languages**, installs a few packages with pip and npm instead of Chocolatey.
5. Installs WSL with Ubuntu (unless `-SkipWSL`).
6. Prints a summary: installed, failed, time taken, whether a reboot is needed.

## Packages

### Favorites

| Package | Description |
|---|---|
| `temurin25` | Eclipse Temurin OpenJDK 25 (LTS). Sets `JAVA_HOME` and `PATH`. |
| `googlechrome` | Google Chrome |
| `microsoft-edge` | Microsoft Edge |
| `notepadplusplus` | Notepad++ text editor |
| `7zip` | Archive tool |
| `vscode` | Visual Studio Code |
| `filezilla` | FTP / SFTP client |
| `winscp` | SFTP / SCP client |
| `pgptool` | PGP encrypt and decrypt |
| `adobereader` | Adobe Acrobat Reader |
| `vlc` | Media player |
| `git` | Git |
| `zoom` | Zoom |
| `mobaxterm` | SSH client with X server |
| `tigervnc` | VNC viewer |
| `gnupg` | GPG encryption |
| `sysinternals` | Microsoft Sysinternals suite |
| `curl` | curl |
| `virtualbox` | VirtualBox VMs |
| `tortoisegit` | Git integration for File Explorer |
| `drawio` | Diagrams |
| `citrix-workspace` | Citrix Workspace (replaces Citrix Receiver) |
| `cpu-z` | Hardware info |
| `intellijidea-community` | IntelliJ IDEA Community |
| `pycharm-community` | PyCharm Community |
| `dbeaver` | Database client |
| `github-desktop` | GitHub Desktop |
| `openssl` | OpenSSL |
| `pgadmin4` | PostgreSQL admin |
| `oracle-sql-developer` | Oracle SQL Developer (asks for your Oracle login, see below) |

### Terminal

| Package | Description |
|---|---|
| `microsoft-windows-terminal` | Windows Terminal |
| `powershell-core` | PowerShell 7 |
| `oh-my-posh` | Prompt themes |
| `starship` | Fast cross-shell prompt (alternative to Oh My Posh) |
| `nerd-fonts-cascadiacode` | Cascadia Code Nerd Font, needed for prompt icons |
| `gsudo` | `sudo` for Windows |

### CLI tools

| Package | Description |
|---|---|
| `ripgrep` | Fast text search (`rg`) |
| `fzf` | Fuzzy finder |
| `jq` | JSON processor |
| `yq` | YAML processor |
| `bat` | `cat` with syntax highlighting |
| `lazygit` | Git terminal UI |
| `delta` | Easier-to-read git diffs |
| `neovim` | Terminal editor |

### Languages & dev stack

| Package | Description |
|---|---|
| `golang` | Go |
| `python3` | Python 3 |
| `uv` | Fast Python package and project manager |
| `nodejs-lts` | Node.js LTS |
| `pnpm` | Node package manager |
| `ruby` | Ruby |
| `rustup.install` | Rust toolchain installer |
| `dotnet-sdk` | .NET SDK |
| `visualstudio2022community` | Visual Studio 2022 Community |
| `maven` | Java build tool |
| `gradle` | Java build tool |
| `graalvm` | GraalVM, latest Java |
| `xampp-81` | Apache, MariaDB, PHP 8.1 |
| `tomcat` | Apache Tomcat |
| `mongodb` | MongoDB server |
| `mongodb-compass` | MongoDB GUI |
| `wingide101` | Wing IDE 101 for Python |
| `vscode-intellicode` | IntelliCode for VS Code |

**Installed with pip / npm after this category:**

| Package | Installed with | Description |
|---|---|---|
| `numpy` | pip | Numerical Python |
| `typescript` | npm | TypeScript compiler |
| `yarn` | npm | Node package manager |
| `serverless` | npm | Serverless Framework |

### Containers & Kubernetes

| Package | Description |
|---|---|
| `docker-desktop` | Docker Desktop |
| `podman-desktop` | Podman Desktop, a free Docker alternative |
| `kubernetes-cli` | `kubectl` |
| `kubernetes-helm` | Helm |
| `k9s` | Kubernetes terminal UI |
| `kubectx` | Switch clusters and namespaces |
| `k3d` | k3s clusters in Docker |
| `kind` | Kubernetes in Docker |
| `minikube` | Local Kubernetes |
| `argocd-cli` | Argo CD CLI |

### Cloud & infrastructure as code

| Package | Description |
|---|---|
| `azure-cli` | Azure CLI |
| `az.powershell` | Azure PowerShell module |
| `azd` | Azure Developer CLI |
| `awscli` | AWS CLI v2 |
| `gcloudsdk` | Google Cloud CLI |
| `gh` | GitHub CLI |
| `terraform` | Terraform |
| `terragrunt` | Terraform wrapper |
| `tflint` | Terraform linter |
| `packer` | Machine image builder |
| `vault` | HashiCorp Vault CLI |
| `chef-workstation` | Chef |

### API & web tools

| Package | Description |
|---|---|
| `postman` | API client |
| `bruno` | Offline, git-friendly API client |
| `insomnia-rest-api-client` | API client |
| `ngrok` | Make a local server reachable from the internet |
| `mkcert` | Trusted local HTTPS certificates |

### Productivity

| Package | Description |
|---|---|
| `powertoys` | Microsoft PowerToys |
| `everything` | Instant file search |
| `sharex` | Screenshots and screen recording |
| `obsidian` | Markdown notes |
| `bitwarden` | Password manager |
| `keepassxc` | Offline password manager |
| `jetbrainstoolbox` | Manages JetBrains IDEs |

### Monitoring & system tools

| Package | Description |
|---|---|
| `prometheus-windows-exporter.install` | Prometheus metrics exporter |
| `wireshark` | Network capture |
| `sandboxie-plus` | Run apps in a sandbox |
| `speedtest` | Ookla Speedtest CLI |
| `teamviewer` | Remote support |
| `adexplorer` | Active Directory browser |
| `sysmon` | System activity logging |
| `autoruns` | Startup program manager |
| `procmon` | Process Monitor |
| `hashmyfiles` | File hashes |
| `malwarebytes` | Malware scanner |
| `ccleaner` | System cleaner |
| `rdm` | Remote Desktop Manager |

### VS Code extensions

| Package | Description |
|---|---|
| `vscode-spring-boot` | Spring Boot tools |
| `vscode-mongodb` | MongoDB for VS Code |

### Non-essentials

| Package | Description |
|---|---|
| `itunes` | iTunes |
| `dropbox` | Dropbox |
| `slack` | Slack |
| `rocketchat` | Rocket.Chat |
| `signal` | Signal |
| `brave` | Brave browser |
| `evernote` | Evernote |
| `chromium` | Chromium |
| `electron` | Electron |
| `etcher` | balenaEtcher (flash USB drives) |
| `tableau-public` | Tableau Public |
| `darktable` | Photo editor |
| `ubiquiti-unifi-controller` | UniFi Network controller |
| `libreoffice-fresh` | LibreOffice |

### Optional

| Item | How to install | Description |
|---|---|---|
| `microsoft-office-deployment` | `-IncludeOffice` | Microsoft 365, 64-bit, without Publisher, OneDrive, OneNote, Lync, Groove |
| WSL + Ubuntu | on by default, `-SkipWSL` to skip | Linux on Windows. After the reboot, open **Ubuntu** from Start to create your Linux user. |
| WhatsApp | Microsoft Store | No longer on Chocolatey |

## Oracle SQL Developer credentials

`oracle-sql-developer` downloads from Oracle, which needs an Oracle account. The script asks for your Oracle login when it gets to that package, so no credentials are stored in the repo. Click **Cancel** to skip it, or run with `-SkipOracle`.

## Customizing

- Add or remove packages in the `$Packages` lists at the top of `setup.ps1`.
- Packages that need extra install options go in `$PackageParams`.
- Keep everything up to date later with:

  ```powershell
  choco upgrade all
  ```

## Troubleshooting

| Problem | Fix |
|---|---|
| "running scripts is disabled on this system" | Run `Set-ExecutionPolicy Bypass -Scope Process -Force` first |
| "Access denied" or "requires elevation" | Open PowerShell as Administrator |
| `choco` not found after install | Close and reopen PowerShell |
| A package fails | Re-run just that one: `choco install <package> --force` |
| See what's installed | `choco list` |
| WSL fails | Turn on virtualization in BIOS/UEFI, then run `wsl --install` |

Logs are saved in `C:\ProgramData\chocolatey\logs\chocolatey.log` and in the script's own log (path printed at the end).

## License

MIT
