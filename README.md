<p align="center"><img src="docs/assets/banner.svg" alt="ROSH: Neo Asmara — Native C++ server files" width="100%"></p>

# Neo Asmara Core++

Precompiled Windows server files for the **ROSH: Neo Asmara development preview**. Game services use C++ and SQLite. Source code is not included.

<p align="center"><a href="#first-run">First run</a> · <a href="#server-panels">Server panels</a> · <a href="#configuration">Configuration</a> · <a href="#requirements">Requirements</a></p>

## Server panels

Actual screenshots supplied from the test installation. Paths and process IDs shown in the pictures belong to that installation.

<table>
<tr><td width="50%"><strong>MainServer</strong><br><img src="docs/assets/mainserver.png" alt="MainServer cluster and operator console"></td><td width="50%"><strong>LoginServer</strong><br><img src="docs/assets/loginserver.png" alt="LoginServer status and logs"></td></tr>
<tr><td><strong>LobbyServer</strong><br><img src="docs/assets/lobbyserver.png" alt="LobbyServer panel"></td><td><strong>WorldServer</strong><br><img src="docs/assets/worldserver.png" alt="WorldServer channel selector"></td></tr>
</table>

## Requirements

| Requirement | Details |
|---|---|
| Operating system | Windows x64; development and local validation use Windows 10 or 11|
| Native libraries | Included `libc++.dll` and `libunwind.dll`; keep them beside the executables |
| Windows components | Windows CNG, DPAPI, Winsock and `winsqlite3.dll` |
| Database engine | SQLite; no separate engine installation |
| PowerShell | Optional convenience script; Windows PowerShell 5.1 or later |
| Website / Python | Not part of this distribution |

## First run

1. Extract the complete Core folder somewhere writable.
2. Double-click `START.cmd`.
3. Register through the matching external-login launcher. There are no pre-created accounts or default passwords.

The eight SQLite databases are already in `Database`, beside `Bin`, `Config` and `Data`. There is no database to locate, import or copy from a separate folder. `START.cmd` performs first-run initialization automatically, starts the native account API and opens MainServer visibly with the four-channel cluster.

Keep the complete folder together. The separate restoration package is optional and is never required to start this Core.

Initialization checks the encrypted content and databases. Its content key is protected for the Windows account running setup. On another computer or Windows account, `START.cmd` performs initialization there automatically; the developer's Windows profile is not required.

Existing runtime databases are preserved. Initialization is not a player reset command.

## Configuration

`Config\server.json` belongs to this installation.

| Setting | Release default |
|---|---|
| Bind address | `127.0.0.1` |
| Native login port | `22001` |
| Account API port | `18290` |
| GM API port | `18292` |
| Installation identity | `neoasmara-public` |

This preview defaults to local development. Public internet hosting and large concurrent-player loads have not been certified.

Move or rename the complete folder rather than individual DLLs. Configure tools and the launcher for the intended installation. An unrelated installation is never stopped automatically to free a port.

`Config\launcher-news.json` provides launcher announcements, news and events without a website.

## Folder guide

| Folder | Purpose |
|---|---|
| `Bin` | Native services, account API, data verification and initialization |
| `Data` | Authenticated encrypted game catalogs |
| `Bootstrap\Database` | Fresh databases for first initialization |
| `Database` | Eight fresh SQLite databases included with this Core; live accounts, characters and persistent state are stored here |
| `Config` | Installation settings and local content key |
| `Logs` / `Dumps` | Runtime diagnostics; excluded from distribution |
| `Licenses` | Dependency notices |
| `Updates` | Small signed release manifest; repair content is read from the configured client distribution |

## Client update source

The Core keeps the signed release manifest in `Updates/manifest.json`. It does not need a full client copy in `Updates/blobs`.

`Config/client-updates.json` points to an existing, intact client distribution. The prepared layout uses `../Client And Launcher`; a renamed adjacent client can also be discovered by its approved protection-list hash. Change `source` if you keep the repair files somewhere else.

The account service serves only files listed in the release manifest and checks their size and SHA-256 before sending them. It keeps the same verified file open throughout transmission. An unavailable or damaged source is rejected; it is never approved by calculating a new baseline.

The Core can start without a repair source. A complete, matching client can still verify itself against the signed manifest; downloading a missing or corrupted client file requires an intact configured source or an optional small approved patch blob. No website is required.

Existing installations with the old full mirror can run `CLEAN_UPDATE_CACHE.cmd`. It verifies the configured client against all signed entries before deleting only the duplicated `Updates/blobs` folder. It preserves the signed manifest, client and databases.

## Updates and shutdown

Use `STATUS.cmd` to list this folder's processes and `STOP.cmd` for an orderly shutdown and database checkpoint. These commands only operate on executables in this installation's `Bin` folder. They never terminate another installation to free a port. PowerShell is not required.

Stop this installation normally before replacing executables or content. Preserve live `Database` files. Client and launcher changes also require matching protected-file lists and a signed update release.

This is a development preview, not a declaration of full retail parity. An intermittent native-memory problem remains under investigation and may affect this preview. Compilation and protocol tests do not establish that every gameplay system is complete.

---

[![Support on Ko-fi](docs/assets/kofi.svg)](https://ko-fi.com/neoasmara)

Donations are optional and do not unlock administrative access.

## License

Copyright © 2026 LuspX_

This repository is part of the **NeoAsmara Project** and is distributed under the **NeoAsmara Project License v1.1 (NAPL)**.

The license permits personal research, local testing, and authorized reverse engineering, while reserving commercial redistribution rights.

See [LICENSE.md](LICENSE.md) for the complete terms.

**NeoAsmara is an independent, unofficial project.**
