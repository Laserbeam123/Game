"""Colour -> painted texture name, shared by gen.py (paths in the data) and make_art.py (the PAA files).
Arma's flat procedural colours wash out on the helper spheres, so monkeys use painted textures like the bloons."""
TAN = [0.95, 0.78, 0.55, 1]
WHITE = [1, 1, 1, 1]


def tex_name(rgba):
    return "c_" + "".join(f"{max(0, min(255, int(round(c * 255)))):02x}" for c in rgba[:3])


def tex_path(rgba):
    return "\\z\\bloonsops\\addons\\main\\data\\" + tex_name(rgba) + "_co.paa"


def tower_colours(towers):
    out = [TAN, WHITE]
    for t in towers:
        if t["kind"] in ("monkey", "farm"):
            out += [t["body_rgba"], t["accent_rgba"]]
    seen, uniq = set(), []
    for c in out:
        if tex_name(c) not in seen:
            seen.add(tex_name(c)); uniq.append(c)
    return uniq
