# Third-party pieces in bloonsops_btd6.exe

The converter ships only redistributable code. It contains **no Ninja Kiwi files**: it reads the player's own
Bloons TD 6 install on their own PC and writes the result there.

| Piece | Licence | Use |
|---|---|---|
| [UnityPy](https://github.com/K0lb3/UnityPy) and its dependencies (lz4, brotli, texture2ddecoder, etcpak, astc-encoder-py, fsspec, attrs, tpk_ar) | MIT / BSD / Apache-2.0 | read Unity asset bundles, decode sprites |
| [fsb5](https://github.com/HearthSim/python-fsb5) (vendored in `tools/btd6/fsb5/`, patched to load the DLLs next to the exe) | MIT | rebuild FSB5 Vorbis audio into OGG |
| libogg, libvorbis (DLLs from the PyOgg wheel) | BSD-3-Clause | used by fsb5 |
| numpy | BSD-3-Clause | DXT5 encoding |
| Pillow | MIT-CMU | image trimming and scaling |
| Python runtime (via PyInstaller) | PSF | |

FMOD (which UnityPy can use for audio) is **not** included: its licence doesn't allow redistribution here.
