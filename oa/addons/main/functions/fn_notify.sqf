// Client: [text, kind] kind: "round" (big text), "error" (hint), "info" (chat).
private ["_text", "_kind"];
if (isDedicated) exitWith {};
_text = _this select 0;
_kind = _this select 1;
switch (_kind) do {
    case "round": { titleText [_text, "PLAIN DOWN", 0.6]; player sideChat _text };
    case "error": { hintSilent _text };
    default { player sideChat _text };
};
