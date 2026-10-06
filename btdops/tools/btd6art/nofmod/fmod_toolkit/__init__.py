"""Stand-in for fmod_toolkit. UnityPy imports it for audio, which Bloon Strike: Altis doesn't extract,
so FMOD's libraries are not shipped. Any audio use fails clearly."""


def __getattr__(name):
    raise RuntimeError("Audio extraction is not included in Bloon Strike: Altis' BTD6 art converter.")
