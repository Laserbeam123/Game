"""Stand-in for fmod_toolkit. UnityPy imports it for audio, which Bloons TD Ops doesn't extract,
so FMOD's libraries are not shipped. Any audio use fails clearly."""


def __getattr__(name):
    raise RuntimeError("Audio extraction is not included in Bloons TD Ops' BTD6 art converter.")
