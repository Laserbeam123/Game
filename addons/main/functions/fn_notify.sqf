// Client: show a message. kind: "round" (big text), "error" (hint), "info" (chat).
params ["_text", ["_kind", "info"]];
if (!hasInterface) exitWith {};
switch (_kind) do {
    case "round": { titleText [format ["<t size='1.6' color='#FFD700' shadow='2'>%1</t>", _text], "PLAIN", 0.4, true, true]; systemChat _text };
    case "error": { hintSilent _text };
    default { systemChat _text };
};
