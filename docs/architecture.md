# How iimatey / iimux / tunnel tie together

Three layers: a **command** you run, a **client binary** it drives, and a **server**
it connects to.

```
  you ──> iimux (the command) ──> ttyd + tunnel ──> tunneld (server)
                                        │                  │
                                        │                  ├─ API:     iimatey.sharing.io
                                        │                  └─ tunnels: *.sharing.io
                                        └─ or asciinema (--stream)
```

## iimux — the command

`iimux` is the one command. A "side" (`left`/`right`) registers a StreamDeck **eye**
and attaches to tmux with a plain `tmux attach`, so the client can roam *every*
session and the deck steers it. Any client — a terminal or a web share — attached
this way **follows the deck together**.

```
iimux left                    # local: attach as the left eye, follow the deck
iimux left --share            # web terminal (ttyd + tunnel), stable UNNAMED url
iimux left --share rv-left    # named:  https://rv-left.sharing.io
iimux left --stream           # asciinema broadcast + audio
```

- **`--share`** runs `ttyd` (serving `iimux <side>`, so browser clients follow too)
  behind a `tunnel`, giving an interactive web terminal at `*.sharing.io`.
- **`--stream`** records/broadcasts via asciinema with linked icecast audio.
- **Per-side keys** (`~/.config/iimux/keys/<side>.key`) make the *unnamed* URL stable
  and let `left` and `right` run at once with distinct URLs. Name it with `--share NAME`.

`iimatey` is a thin alias: `iimatey left` == `iimux --share left`.

## tunnel — the client binary

`tunnel` (from `ii/wgtunnel`) registers a WireGuard tunnel with the server and proxies
a local port out to a public URL. Default API is `iimatey.sharing.io`. Each concurrent
tunnel needs **its own key** (`--wg-key-file`) — iimux handles that per side.

## tunneld — the server

`tunneld` (in k8s, `apps/`) terminates tunnels:
- **API** at `iimatey.sharing.io` (`TUNNELD_BASE_URL`); `GET /` redirects to this repo.
- **Tunnels** at `*.sharing.io` (`TUNNELD_TUNNEL_DOMAIN`).
- Reached publicly via an OCI edge box → tailscale → Traefik (wildcard TLS).

## Install (for others)

```
curl -fsSL https://raw.githubusercontent.com/ii/matey/canon/iimatey-setup.sh | bash
```

Installs `ttyd`, `tmux`, the `tunnel` binary (from an `ii/wgtunnel` release, pinned in
`iimatey-setup.sh`), and the `iimatey` script — all pointed at `iimatey.sharing.io`.
