# How iimatey works

`iimatey` shares a terminal — a tmux session — over the web at a public URL. It
glues two pieces together: **ttyd** (a browser terminal) and the **tunnel** client
(from `ii/wgtunnel`), which exposes the local ttyd port at a public `*.sharing.io`
address.

```
  you ──> iimatey ──> ttyd (web terminal) + tunnel ──> tunneld (server)
                                                            ├─ API:     iimatey.sharing.io
                                                            └─ tunnels: *.sharing.io
```

## iimatey — the script

```
iimatey start     # ttyd serving `tmux at` + a tunnel -> https://<name>.sharing.io
iimatey status    # show the tunnel URL and tmux state
iimatey stop      # stop ttyd + tunnel (tmux is left running)
iimatey connect   # attach locally to the same tmux session
```

Anyone opening the URL gets a live, interactive terminal in their browser.

## tunnel — the client binary

`tunnel` (from `ii/wgtunnel`) registers a WireGuard tunnel with the server and
proxies a local port out to a public URL. Its default API is `iimatey.sharing.io`.
Each concurrent tunnel needs **its own key** (`--wg-key-file`).

## tunneld — the server

`tunneld` terminates the tunnels:
- **API** at `iimatey.sharing.io` (`TUNNELD_BASE_URL`); `GET /` redirects to this repo.
- **Tunnels** at `*.sharing.io` (`TUNNELD_TUNNEL_DOMAIN`).

## Install

```
curl -fsSL https://raw.githubusercontent.com/ii/matey/canon/iimatey-setup.sh | bash
```

Installs `ttyd`, `tmux`, the `tunnel` binary (from an `ii/wgtunnel` release, pinned
in `iimatey-setup.sh`), and the `iimatey` script — all pointed at
`iimatey.sharing.io`.
