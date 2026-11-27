// Display-only localization. User names, package matching and saved settings keep their original values.
function ModList_Language() {
    if (!variable_global_exists("__LANG_ENUM") || !variable_global_exists("__ALL_LANGS__")) return 0;
    var _langs = variable_global_get("__ALL_LANGS__");
    var _index = variable_global_get("__LANG_ENUM");
    if (!is_array(_langs) || !is_real(_index) || _index < 0 || _index >= array_length(_langs)) return 0;
    if (_langs[_index] == "chinese_simplified") return 1;
    if (_langs[_index] == "chinese_traditional") return 2;
    return 0;
}

function ModList_Text(_text) {
    var _language = ModList_Language();
    if (_language == 0) return _text;
    switch (_text) {
@TRANSLATION_CASES@
    }
    return _text;
}

function ModList_Message(_text) {
    var _prefix = "Removed from ";
    if (string_pos(_prefix, _text) == 1) {
        return ModList_Text(_prefix) + string_delete(_text, 1, string_length(_prefix));
    }
    var _suffix = " hook(s) could not be matched to a mod";
    var _at = string_pos(_suffix, _text);
    if (_at > 0 && _at + string_length(_suffix) - 1 == string_length(_text)) {
        return string_copy(_text, 1, _at - 1) + ModList_Text(_suffix);
    }
    return ModList_Text(_text);
}

function ModList_Font() {
    return variable_global_get("__FONTS").normal;
}
