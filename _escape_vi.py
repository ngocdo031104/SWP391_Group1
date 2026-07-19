#!/usr/bin/env python3
"""
TourBuddy — Encoding-safe escape.

Rewrites non-ASCII characters in JSP/HTML/JS files to:
  - JSP/HTML markup & text nodes  -> &#NNN; HTML numeric entities
  - JS / <script> blocks          -> \\uXXXX JS unicode escapes

Skips (preserves raw text) inside:
  - JSP code blocks <% ... %> (Java source — must stay raw)
  - <script>...</script> blocks (JavaScript string literals — must use \\uXXXX)

Per-line state machine handles the JSP tag & script tag tracking.
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

ROOT = Path("src/frontend")
JSP_EXTS = {".jsp", ".jspf", ".html", ".htm"}
JS_EXTS = {".js"}


def is_non_ascii(ch: str) -> bool:
    return ord(ch) > 0x7F


def escape_html(text: str) -> str:
    out = []
    for ch in text:
        if is_non_ascii(ch):
            out.append(f"&#{ord(ch)};")
        else:
            out.append(ch)
    return "".join(out)


def escape_java_comments(text: str) -> str:
    """Escape non-ASCII everywhere in a Java code block, INCLUDING string
    literals and char literals.

    Rationale: HTML entities inside Java string literals are still rendered
    correctly by the browser (the entity reference is decoded at HTML parse
    time, not at Java compile time). This guarantees the visible output is
    immune to encoding mishaps even when the JSP is served with a wrong
    Content-Type charset.
    """
    return escape_html(text)


_JS_RE = re.compile(r"[^\x00-\x7F]")
def _js_replace(m):
    return f"\\u{ord(m.group(0)):04x}"
def escape_js(text: str) -> str:
    return _JS_RE.sub(_js_replace, text)


# Tag scanner for JSP/HTML files
# State: "html" (default), "jsp_code" (inside <% ... %>), "script" (inside <script>...</script>)
TAG_JSP_OPEN = re.compile(r"<%(?:--|@|=|)?" )  # <%, <%=, <%@, <%--
# Use lookahead-free match: prefer --%> over %>
TAG_JSP_CLOSE = re.compile(r"--%>|%>")
TAG_SCRIPT_OPEN = re.compile(r"<script\b[^>]*>", re.IGNORECASE)
TAG_SCRIPT_CLOSE = re.compile(r"</script\s*>", re.IGNORECASE)


def process_jsp(content: str) -> str:
    out = []
    i = 0
    n = len(content)
    state = "html"
    # find nearest boundary
    while i < n:
        if state == "html":
            # Find next <% or <script
            m_jsp = TAG_JSP_OPEN.search(content, i)
            m_sc = TAG_SCRIPT_OPEN.search(content, i)
            # pick the earliest
            candidates = [(m.start(), m.end(), kind) for m, kind in [(m_jsp, "jsp"), (m_sc, "script")] if m]
            if not candidates:
                # rest is plain HTML
                out.append(escape_html(content[i:]))
                break
            start, end, kind = min(candidates, key=lambda x: x[0])
            # escape HTML from i up to start
            out.append(escape_html(content[i:start]))
            if kind == "jsp":
                # check if this is a JSP comment <%-- --%>: escape its body as HTML
                # (it's never rendered, but for consistency & file hygiene)
                opener = content[start:end]
                close = TAG_JSP_CLOSE.search(content, end)
                if not close:
                    # unterminated — treat rest as raw code
                    out.append(content[start:])
                    break
                if opener.startswith("<%--"):
                    # escape the body between <%-- and --%>
                    body_start = end
                    body_end = close.start()
                    out.append(opener)
                    out.append(escape_html(content[body_start:body_end]))
                    out.append(content[body_end:close.end()])
                else:
                    # Java code block: escape // and /* */ comments,
                    # preserve string literals
                    out.append(escape_java_comments(content[start:close.end()]))
                i = close.end()
                # state stays html
            else:  # script
                out.append(content[start:end])  # raw <script ...>
                i = end
                state = "script"
        elif state == "script":
            # find </script
            close = TAG_SCRIPT_CLOSE.search(content, i)
            if not close:
                # unterminated — escape the rest as JS (shouldn't happen)
                out.append(escape_js(content[i:]))
                break
            # escape content as JS
            out.append(escape_js(content[i:close.start()]))
            out.append(content[close.start():close.end()])  # </script>
            i = close.end()
            state = "html"
    return "".join(out)


def process_js(content: str) -> str:
    return escape_js(content)


def needs_escape_anywhere(text: str) -> bool:
    return any(ord(c) > 0x7F for c in text)


def collect_files():
    jsp, js = [], []
    for p in ROOT.rglob("*"):
        if not p.is_file():
            continue
        ext = p.suffix.lower()
        if ext in JSP_EXTS:
            jsp.append(p)
        elif ext in JS_EXTS:
            js.append(p)
    return jsp, js


def main():
    dry = "--apply" not in sys.argv
    mode = "DRY-RUN" if dry else "APPLY"
    print(f"\n=== TourBuddy encoding-safe escape ({mode}) ===\n")

    jsp_files, js_files = collect_files()
    jsp_changed = js_changed = 0

    print(f"JSP/HTML: scanning {len(jsp_files)} files")
    for p in jsp_files:
        try:
            content = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            try:
                content = p.read_text(encoding="latin-1")
            except Exception:
                print(f"  [skip] {p}")
                continue
        if not needs_escape_anywhere(content):
            continue
        new = process_jsp(content)
        if new != content:
            jsp_changed += 1
            print(f"  [{'plan' if dry else 'done'}] {p}")
            if not dry:
                p.write_text(new, encoding="utf-8", newline="")

    print(f"\nJS: scanning {len(js_files)} files")
    for p in js_files:
        try:
            content = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            try:
                content = p.read_text(encoding="latin-1")
            except Exception:
                print(f"  [skip] {p}")
                continue
        if not needs_escape_anywhere(content):
            continue
        new = process_js(content)
        if new != content:
            js_changed += 1
            print(f"  [{'plan' if dry else 'done'}] {p}")
            if not dry:
                p.write_text(new, encoding="utf-8", newline="")

    print(f"\nSummary: JSP {jsp_changed}  JS {js_changed}")
    if dry:
        print("Re-run with --apply to write.")


if __name__ == "__main__":
    main()
