"""Build ModList with ten native language objects and localized display text."""
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parent
VERSION = '1.4.1'
PACKAGE_NAME = f'Modlist_v{VERSION}.zip'
SCRIPT_NAME = 'scripts/Modlist@main.json'
LANGUAGES = ('english', 'spanish', 'french', 'german', 'portuguese', 'japanese',
             'korean', 'chinese_traditional', 'chinese_simplified', 'russian')


def source_text():
    catalog = json.loads((ROOT / 'src/ui_text.json').read_text(encoding='utf-8'))
    cases = []
    for english, translated in catalog.items():
        if not isinstance(translated, list) or len(translated) != 2 or not all(
                isinstance(value, str) and value for value in translated):
            raise ValueError(f'Invalid UI translations: {english}')
        literals = [json.dumps(value, ensure_ascii=False) for value in (english, *translated)]
        cases.append(f'        case {literals[0]}: return (_language == 1) ? {literals[1]} : {literals[2]};')
    helper = (ROOT / 'src/localization.gml').read_text(encoding='utf-8')
    helper = helper.replace('@TRANSLATION_CASES@', '\n'.join(cases))
    main = (ROOT / 'src/modlist.gml').read_text(encoding='utf-8')
    if main.count('@VERSION@') != 3:
        raise ValueError('Expected version tokens in author header, report and panel')
    return helper + '\n' + main.replace('@VERSION@', VERSION)


def build(destination=None):
    if not re.fullmatch(r'(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)', VERSION):
        raise ValueError('VERSION must use x.x.x')
    destination = Path(destination) if destination else ROOT / PACKAGE_NAME
    source = source_text()
    record = {'id': 5470, 'key': 'Modlist@main', 'event': 'E_CS_EVENT.None',
              'code': source.replace(',', '#$#').replace('"', '%$%')}
    entries = {SCRIPT_NAME: json.dumps(record, ensure_ascii=False, indent=2).encode('utf-8')}
    # Preserve the original item records byte for byte, including GameMaker's accepted trailing commas.
    for index in range(1, 17):
        name = f'items/Modlist@spare_{index:02}.json'
        entries[name] = (ROOT / 'src' / name).read_bytes()
    entries.update({language: b'{}' for language in LANGUAGES})
    destination.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED) as archive:
        archive.comment = f'ModList {VERSION} | Original author: obfy | Language-switch compatibility fix'.encode('ascii')
        for name, payload in entries.items():
            info = zipfile.ZipInfo(name, (2026, 11, 15, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, payload)
    with zipfile.ZipFile(destination) as archive:
        assert archive.testzip() is None
        assert len(archive.namelist()) == len(set(archive.namelist())) == 27
        assert set(archive.namelist()) == set(entries)
        for name, payload in entries.items():
            assert archive.read(name) == payload
        restored = json.loads(archive.read(SCRIPT_NAME))['code']
        assert restored.replace('#$#', ',').replace('%$%', '"') == source
        for language in LANGUAGES:
            assert json.loads(archive.read(language)) == {}
    return destination


if __name__ == '__main__':
    print(build())
