# Windows Setup

Sets up a Windows development machine in one go using [Chocolatey](https://chocolatey.org/). The script installs Chocolatey, then installs my usual browsers, editors, languages, cloud CLIs, and admin tools.

## Requirements

- Windows 10 or 11
- PowerShell, **run as Administrator**
- Internet access
- Enough disk space (the full list is roughly 20–30 GB)

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

   > The file must have the `.ps1` extension for PowerShell to run it.

3. Reboot when it finishes. Some packages (Docker Desktop, VirtualBox, Sysmon) need a restart.

### Options

| Parameter | What it does |
|---|---|
| `-Skip <categories>` | Leave out categories: `Favorites`, `Languages`, `CLIs`, `Monitoring`, `VSCodeExtensions`, `NonEssentials` |
| `-Only <categories>` | Install only these categories |
| `-IncludeOffice` | Also install Microsoft 365 (64-bit) |
| `-SkipOracle` | Don't install Oracle SQL Developer (otherwise you're prompted for your Oracle login) |
| `-LogPath <file>` | Where to save the log (default: `%TEMP%\windows-setup-<timestamp>.log`) |

```powershell
.\setup.ps1 -Skip NonEssentials,Monitoring    # lean work machine
.\setup.ps1 -Only CLIs -SkipOracle            # just the cloud/k8s CLIs
Get-Help .\setup.ps1 -Full                    # built-in help
```

If a package fails, the script keeps going and lists the failures at the end.

### Run it straight from GitHub

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/allwindurairaj/Windows_setup/main/setup.ps1'))
```

## What the script does

1. Installs Chocolatey.
2. Turns on `allowGlobalConfirmation`, so packages install without a prompt for each one.
3. Installs the packages below.

## Packages

### Favorites

| Category | Packages |
|---|---|
| Browsers | `googlechrome`, `microsoft-edge` |
| Editors & IDEs | `vscode`, `notepadplusplus`, `intellijidea-community`, `pycharm-community` |
| Java | `jdk8` |
| Databases | `oracle-sql-developer`, `dbeaver`, `pgadmin4` |
| Git | `git`, `tortoisegit`, `github-desktop` |
| File transfer & remote | `filezilla`, `winscp`, `mobaxterm`, `tigervnc`, `citrix-workspace` |
| Security & crypto | `pgptool`, `gnupg`, `openssl` |
| Utilities | `7zip`, `curl`, `sysinternals`, `cpu-z`, `drawio`, `postman` |
| Media & docs | `adobereader`, `vlc` |
| Virtualization | `virtualbox` |
| Communication | `zoom` |

### Programming languages & dev stack

`golang`, `python3`, `nodejs`, `ruby`, `typescript`, `graalvm-java8`, `numpy` (via pip), `chef-workstation`, `terraform`, `xampp-80`, `docker-desktop`, `mongodb`, `mongodb-compass`, `k3d`, `wingide101`, `vscode-intellicode`, `traefik`, `tomcat`

### CLIs

| Tool | Package |
|---|---|
| Azure CLI | `azure-cli` |
| Azure PowerShell | `az.powershell` |
| AWS CLI | `awscli` |
| GitHub CLI | `gh` |
| kubectl | `kubernetes-cli` |
| Argo CD | `argocd-cli` |
| Serverless Framework | `serverless` |

### Monitoring & system tools

`prometheus-windows-exporter.install`, `wireshark`, `sandboxie-plus`, `speedtest`, `teamviewer`, `adexplorer`, `sysmon`, `autoruns`, `procmon`, `hashmyfiles`, `malwarebytes`, `ccleaner`, `rdmfree`

### VS Code extensions

`vscode-spring-boot`, `vscode-mongodb`

### Non-essentials

`itunes`, `dropbox`, `slack`, `rocketchat`, `signal`, `brave`, `evernote`, `chromium`, `electron`, `etcher`, `tableau-public`, `darktable`, `whatsapp`, `ubiquiti-unifi-controller`, `libreoffice-fresh`

### Optional: Microsoft Office

Not installed by default. Run with `-IncludeOffice` to install 64-bit Microsoft 365 without Publisher, OneDrive, OneNote, Lync, and Groove:

```powershell
.\setup.ps1 -IncludeOffice
```

## Oracle SQL Developer credentials

`oracle-sql-developer` downloads from Oracle, which needs an Oracle account. The script asks for your Oracle login when it gets to that package, so no credentials are stored in the repo. Click **Cancel** to skip it, or run with `-SkipOracle`.

## Customizing

- Add or remove packages in the `$Packages` lists at the top of `setup.ps1`.
- Remove the **Non-essentials** section for a lean work machine.
- Keep everything up to date later with:

  ```powershell
  choco upgrade all
  ```

## Troubleshooting

| Problem | Fix |
|---|---|
| "running scripts is disabled on this system" | Run `Set-ExecutionPolicy Bypass -Scope Process -Force` first |
| "Access denied" | Open PowerShell as Administrator |
| `choco` not found after install | Close and reopen PowerShell |
| A package fails | Re-run just that one: `choco install <package> --force` |
| See what's installed | `choco list` |

Logs are saved in `C:\ProgramData\chocolatey\logs\chocolatey.log`.

## License

MIT
