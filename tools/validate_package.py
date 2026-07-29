#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / 'app'
errors: list[str] = []
notes: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


def check_json() -> None:
    for path in ROOT.rglob('*.json'):
        try:
            json.loads(path.read_text(encoding='utf-8'))
        except Exception as exc:
            fail(f'JSON inválido: {path.relative_to(ROOT)}: {exc}')


def check_yaml() -> None:
    try:
        import yaml  # type: ignore
    except Exception:
        notes.append('PyYAML no disponible; YAML no fue parseado por Python.')
        return
    for pattern in ('*.yaml', '*.yml'):
        for path in ROOT.rglob(pattern):
            try:
                yaml.safe_load(path.read_text(encoding='utf-8'))
            except Exception as exc:
                fail(f'YAML inválido: {path.relative_to(ROOT)}: {exc}')


class Parser(HTMLParser):
    pass


def check_html() -> None:
    for path in ROOT.rglob('*.html'):
        try:
            Parser().feed(path.read_text(encoding='utf-8'))
        except Exception as exc:
            fail(f'HTML inválido: {path.relative_to(ROOT)}: {exc}')


def check_js() -> None:
    node = subprocess.run(['bash', '-lc', 'command -v node'], text=True, capture_output=True)
    if node.returncode != 0:
        notes.append('Node.js no disponible; JavaScript no fue validado con node --check.')
        return
    for path in list(ROOT.rglob('*.js')):
        result = subprocess.run(['node', '--check', str(path)], text=True, capture_output=True)
        if result.returncode != 0:
            fail(f'JavaScript inválido: {path.relative_to(ROOT)}: {result.stderr.strip()}')
    gs = ROOT / 'google_apps_script' / 'Code.gs'
    if gs.exists():
        temp = ROOT / 'tools' / '.Code.validation.js'
        temp.write_text(gs.read_text(encoding='utf-8'), encoding='utf-8')
        result = subprocess.run(['node', '--check', str(temp)], text=True, capture_output=True)
        temp.unlink(missing_ok=True)
        if result.returncode != 0:
            fail(f'Apps Script inválido: {result.stderr.strip()}')


def strip_dart(text: str) -> str:
    out: list[str] = []
    i = 0
    n = len(text)
    state = 'code'
    quote = ''
    triple = False
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ''
        if state == 'code':
            if ch == '/' and nxt == '/':
                state = 'line_comment'; out.extend('  '); i += 2; continue
            if ch == '/' and nxt == '*':
                state = 'block_comment'; out.extend('  '); i += 2; continue
            if ch in ('\"', "'"):
                quote = ch
                triple = text[i:i+3] == ch * 3
                state = 'string'
                if triple:
                    out.extend('   '); i += 3
                else:
                    out.append(' '); i += 1
                continue
            out.append(ch); i += 1; continue
        if state == 'line_comment':
            if ch == '\n': state = 'code'; out.append('\n')
            else: out.append(' ')
            i += 1; continue
        if state == 'block_comment':
            if ch == '*' and nxt == '/':
                out.extend('  '); i += 2; state = 'code'
            else:
                out.append('\n' if ch == '\n' else ' '); i += 1
            continue
        if state == 'string':
            if ch == '\\':
                out.append(' '); i += 1
                if i < n: out.append('\n' if text[i] == '\n' else ' '); i += 1
                continue
            if triple and text[i:i+3] == quote * 3:
                out.extend('   '); i += 3; state = 'code'; continue
            if not triple and ch == quote:
                out.append(' '); i += 1; state = 'code'; continue
            out.append('\n' if ch == '\n' else ' '); i += 1
    if state in ('string', 'block_comment'):
        raise ValueError(f'estado sin cerrar: {state}')
    return ''.join(out)


def check_dart() -> None:
    pairs = {')': '(', ']': '[', '}': '{'}
    opens = set(pairs.values())
    import_re = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"]", re.MULTILINE)
    for path in APP.rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        try:
            clean = strip_dart(text)
        except Exception as exc:
            fail(f'Dart cadena/comentario inválido: {path.relative_to(ROOT)}: {exc}')
            continue
        stack: list[tuple[str, int]] = []
        line = 1
        for ch in clean:
            if ch == '\n':
                line += 1
                continue
            if ch in opens:
                stack.append((ch, line))
            elif ch in pairs:
                if not stack or stack[-1][0] != pairs[ch]:
                    fail(f'Dart delimitador inesperado {ch}: {path.relative_to(ROOT)}:{line}')
                    break
                stack.pop()
        else:
            if stack:
                ch, line = stack[-1]
                fail(f'Dart delimitador sin cerrar {ch}: {path.relative_to(ROOT)}:{line}')
        for match in import_re.finditer(text):
            target = match.group(1)
            if target.startswith(('dart:', 'package:')):
                continue
            resolved = (path.parent / target).resolve()
            if not resolved.exists():
                fail(f'Import relativo inexistente: {path.relative_to(ROOT)} -> {target}')


def check_assets() -> None:
    required = [
        APP / 'assets/images/nexo_360_icon.png',
        APP / 'assets/images/nexo_360_logo.png',
        APP / 'assets/images/juventud_2026.png',
        APP / 'assets/images/croquis_evento.png',
        ROOT / 'web/eventos/assets/croquis-evento.png',
    ]
    for path in required:
        if not path.exists() or path.stat().st_size == 0:
            fail(f'Asset ausente: {path.relative_to(ROOT)}')


def check_firestore_collections() -> None:
    rules = (ROOT / 'firebase/firestore.rules').read_text(encoding='utf-8')
    dart = '\n'.join(p.read_text(encoding='utf-8') for p in APP.rglob('*.dart'))
    js = '\n'.join(p.read_text(encoding='utf-8') for p in (ROOT / 'web').rglob('*.js'))
    collections = set(re.findall(r"collection\(['\"]([A-Za-z0-9_\-]+)['\"]\)", dart + '\n' + js))
    matches = set(re.findall(r"match\s+/([A-Za-z0-9_\-]+)/\{", rules))
    ignored = {'mail'}
    missing = sorted(collections - matches - ignored)
    if missing:
        fail('Colecciones sin bloque explícito en Firestore Rules: ' + ', '.join(missing))
    notes.append(f'Colecciones detectadas: {len(collections)}; bloques de reglas: {len(matches)}.')


def check_required_features() -> None:
    required_files = [
        'lib/features/portal/activities_screen.dart',
        'lib/features/portal/announcements_screen.dart',
        'lib/features/portal/courses_screen.dart',
        'lib/features/portal/timetable_screen.dart',
        'lib/features/portal/diary_screen.dart',
        'lib/features/portal/grades_screen.dart',
        'lib/features/portal/school_chat_screen.dart',
        'lib/features/qr/qr_hub_screen.dart',
        'lib/features/events/events_hub_screen.dart',
        'lib/features/events/live_map_screen.dart',
        'lib/features/events/event_operations_screen.dart',
        'lib/features/events/registration_admin_screen.dart',
        'lib/features/admin/technical_admin_screen.dart',
        'lib/features/profile/profile_screen.dart',
    ]
    for rel in required_files:
        if not (APP / rel).exists():
            fail(f'Módulo requerido ausente: app/{rel}')


def main() -> int:
    check_json()
    check_yaml()
    check_html()
    check_js()
    check_dart()
    check_assets()
    check_firestore_collections()
    check_required_features()
    report = ROOT / 'docs/09_VALIDACION_TECNICA_REALIZADA.md'
    lines = [
        '# Validación técnica realizada',
        '',
        'Este paquete fue validado de forma estática dentro del entorno de generación.',
        '',
        '## Comprobaciones ejecutadas',
        '',
        '- JSON parseable.',
        '- YAML parseable cuando PyYAML está disponible.',
        '- JavaScript y Google Apps Script comprobados con `node --check`.',
        '- HTML procesable.',
        '- Imports relativos de Dart existentes.',
        '- Delimitadores, cadenas y comentarios de Dart balanceados mediante un analizador léxico local.',
        '- Assets de marca y croquis presentes.',
        '- Colecciones usadas por la app con bloques explícitos en Firestore Rules.',
        '- Pantallas fundamentales presentes.',
        '',
        '## Resultado',
        '',
    ]
    if errors:
        lines.append('**Se detectaron errores:**')
        lines.extend(f'- {item}' for item in errors)
    else:
        lines.append('**Todas las validaciones estáticas finalizaron correctamente.**')
    if notes:
        lines.extend(['', '## Notas', ''])
        lines.extend(f'- {item}' for item in notes)
    lines.extend([
        '',
        '## Límite de esta validación',
        '',
        'El entorno de generación no contiene Flutter, Android SDK ni Visual Studio con herramientas C++. Por eso no se afirma que el APK o el ejecutable hayan sido compilados aquí. El ZIP incluye scripts y GitHub Actions que ejecutan `flutter analyze`, `flutter test`, la compilación Android y la compilación Windows en entornos con las herramientas oficiales.',
    ])
    report.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print('\n'.join(lines))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
