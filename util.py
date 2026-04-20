#!/usr/bin/env python3
"""Export markdown files to PDF using reportlab.

Handles headings, paragraphs, bullet lists, fenced code blocks,
markdown tables (with header shading and grid), and inline images.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import List, Optional

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import (
    Image as RLImage,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

from PIL import Image as PILImage


PAGE_W, PAGE_H = letter
MARGIN = inch
CONTENT_W = PAGE_W - 2 * MARGIN  # 6.5 inches


# ---------------------------------------------------------------------------
# Style definitions
# ---------------------------------------------------------------------------

def _styles() -> dict:
    s = {}
    s["h1"] = ParagraphStyle(
        "H1",
        fontName="Helvetica-Bold",
        fontSize=20,
        leading=24,
        spaceBefore=16,
        spaceAfter=6,
        textColor=colors.HexColor("#1a3d5c"),
    )
    s["h2"] = ParagraphStyle(
        "H2",
        fontName="Helvetica-Bold",
        fontSize=14,
        leading=18,
        spaceBefore=14,
        spaceAfter=4,
        textColor=colors.HexColor("#1a3d5c"),
        borderPadding=(0, 0, 2, 0),
    )
    s["h3"] = ParagraphStyle(
        "H3",
        fontName="Helvetica-Bold",
        fontSize=12,
        leading=15,
        spaceBefore=10,
        spaceAfter=3,
        textColor=colors.HexColor("#333333"),
    )
    s["body"] = ParagraphStyle(
        "Body",
        fontName="Helvetica",
        fontSize=10,
        leading=15,
        spaceBefore=2,
        spaceAfter=6,
    )
    s["bullet"] = ParagraphStyle(
        "Bullet",
        fontName="Helvetica",
        fontSize=10,
        leading=14,
        leftIndent=18,
        spaceBefore=3,
        spaceAfter=6,
    )
    s["code_block"] = ParagraphStyle(
        "CodeBlock",
        fontName="Courier",
        fontSize=9,
        leading=13,
        spaceBefore=4,
        spaceAfter=4,
        leftIndent=10,
        rightIndent=10,
        backColor=colors.HexColor("#F2F2F2"),
    )
    s["caption"] = ParagraphStyle(
        "Caption",
        fontName="Helvetica-Oblique",
        fontSize=9,
        leading=12,
        alignment=TA_CENTER,
        textColor=colors.grey,
        spaceAfter=6,
    )
    s["th"] = ParagraphStyle(
        "TH",
        fontName="Helvetica-Bold",
        fontSize=9,
        leading=12,
        textColor=colors.white,
    )
    s["td"] = ParagraphStyle(
        "TD",
        fontName="Helvetica",
        fontSize=9,
        leading=12,
    )
    return s


# ---------------------------------------------------------------------------
# Inline markdown cleaning
# ---------------------------------------------------------------------------

def _clean(text: str) -> str:
    """Convert limited markdown inline syntax to reportlab XML."""
    # Extract markdown links before escaping so URLs are preserved
    # Replace [text](url) with a placeholder, restore as clickable link after escaping
    link_store: list = []

    def _stash_link(m: re.Match) -> str:
        link_store.append((m.group(1), m.group(2)))
        return f"\x00LINK{len(link_store) - 1}\x00"

    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", _stash_link, text)

    # Escape XML special chars
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    # Bold
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    # Italic
    text = re.sub(r"\*([^*]+)\*", r"<i>\1</i>", text)
    # Inline code → monospace
    text = re.sub(r"`([^`]*)`", r"<font name='Courier'>\1</font>", text)

    # Restore markdown links as clickable ReportLab links
    for idx, (label, url) in enumerate(link_store):
        label_esc = label.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        url_esc = url.replace("&", "&amp;")
        replacement = f'<link href="{url_esc}"><u><font color="blue">{label_esc}</font></u></link>'
        text = text.replace(f"\x00LINK{idx}\x00", replacement)

    return text.strip()


# ---------------------------------------------------------------------------
# Table builder
# ---------------------------------------------------------------------------

_HEADER_BG = colors.HexColor("#2C5F8A")
_ALT_BG = colors.HexColor("#EBF3FB")
_GRID_COLOR = colors.HexColor("#AAAAAA")


def _is_sep(row: str) -> bool:
    cells = [c.strip() for c in row.strip().strip("|").split("|")]
    return bool(cells) and all(re.fullmatch(r"[:\-\s]+", c or "") for c in cells)


def _build_table(raw_rows: List[str], st: dict) -> Optional[Table]:
    data_rows = [r for r in raw_rows if not _is_sep(r)]
    if not data_rows:
        return None

    parsed: List[List[str]] = []
    for row in data_rows:
        cells = [c.strip() for c in row.strip().strip("|").split("|")]
        parsed.append(cells)

    ncols = max(len(r) for r in parsed)
    for row in parsed:
        while len(row) < ncols:
            row.append("")

    # Proportional column widths based on natural character lengths
    natural = [max(len(row[i]) for row in parsed) for i in range(ncols)]
    total_chars = sum(natural) or 1
    col_widths = [max(0.5 * inch, CONTENT_W * n / total_chars) for n in natural]
    # Scale to fit exactly
    scale = CONTENT_W / sum(col_widths)
    col_widths = [w * scale for w in col_widths]

    # Build Paragraph cells
    rl_data: List[List[Paragraph]] = []
    for ri, row in enumerate(parsed):
        cell_st = st["th"] if ri == 0 else st["td"]
        rl_data.append([Paragraph(_clean(row[ci]), cell_st) for ci in range(ncols)])

    t = Table(rl_data, colWidths=col_widths, repeatRows=1, hAlign="LEFT")

    ts_cmds = [
        # Header row
        ("BACKGROUND", (0, 0), (-1, 0), _HEADER_BG),
        ("TEXTCOLOR",  (0, 0), (-1, 0), colors.white),
        ("FONTNAME",   (0, 0), (-1, 0), "Helvetica-Bold"),
        ("LINEBELOW",  (0, 0), (-1, 0), 1.5, colors.HexColor("#1a3d5c")),
        # Grid
        ("GRID",       (0, 0), (-1, -1), 0.5, _GRID_COLOR),
        # Padding
        ("TOPPADDING",    (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING",   (0, 0), (-1, -1), 6),
        ("RIGHTPADDING",  (0, 0), (-1, -1), 6),
        ("VALIGN",        (0, 0), (-1, -1), "TOP"),
    ]
    # Alternating row shading for data rows
    for ri in range(1, len(rl_data)):
        if ri % 2 == 0:
            ts_cmds.append(("BACKGROUND", (0, ri), (-1, ri), _ALT_BG))

    t.setStyle(TableStyle(ts_cmds))
    return t


# ---------------------------------------------------------------------------
# Markdown → reportlab flowables
# ---------------------------------------------------------------------------

def _to_flowables(text: str, source_dir: Path, st: dict) -> list:
    flowables = []
    lines = text.splitlines()
    i = 0

    while i < len(lines):
        raw = lines[i]
        stripped = raw.strip()

        # ── Blank line ──────────────────────────────────────────────────────
        if not stripped:
            flowables.append(Spacer(1, 0.08 * inch))
            i += 1
            continue

        # ── Fenced code block ───────────────────────────────────────────────
        if stripped.startswith("```"):
            i += 1
            code_lines: List[str] = []
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code_lines.append(
                    lines[i]
                    .replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                )
                i += 1
            if i < len(lines):
                i += 1
            code_xml = "<br/>".join(code_lines)
            flowables.append(Paragraph(code_xml, st["code_block"]))
            flowables.append(Spacer(1, 0.04 * inch))
            continue

        # ── Inline image ────────────────────────────────────────────────────
        img_m = re.match(r"^!\[([^\]]*)\]\(([^)]+)\)", stripped)
        if img_m:
            alt = img_m.group(1)
            img_path = source_dir / img_m.group(2)
            if img_path.exists():
                try:
                    with PILImage.open(img_path) as pil:
                        pw, ph = pil.size
                    max_w = CONTENT_W
                    max_h = 4.5 * inch
                    scale = min(max_w / pw, max_h / ph, 1.0)
                    flowables.append(Spacer(1, 0.1 * inch))
                    flowables.append(
                        RLImage(str(img_path), width=pw * scale, height=ph * scale)
                    )
                    if alt:
                        flowables.append(Paragraph(alt, st["caption"]))
                    flowables.append(Spacer(1, 0.1 * inch))
                except Exception:
                    flowables.append(Paragraph(f"[Image: {alt}]", st["body"]))
            else:
                flowables.append(Paragraph(f"[Image not found: {alt}]", st["body"]))
            i += 1
            continue

        # ── Heading ─────────────────────────────────────────────────────────
        h_m = re.match(r"^(#{1,6})\s+(.+)$", stripped)
        if h_m:
            level = len(h_m.group(1))
            content = _clean(h_m.group(2))
            style = st["h1"] if level == 1 else st["h2"] if level == 2 else st["h3"]
            flowables.append(Paragraph(content, style))
            i += 1
            continue

        # ── Table ───────────────────────────────────────────────────────────
        if stripped.startswith("|"):
            raw_rows = [stripped]
            i += 1
            while i < len(lines) and lines[i].strip().startswith("|"):
                raw_rows.append(lines[i].strip())
                i += 1
            t = _build_table(raw_rows, st)
            if t:
                flowables.append(t)
            flowables.append(Spacer(1, 0.1 * inch))
            continue

        # ── Bullet / numbered list item ─────────────────────────────────────
        li_m = re.match(r"^([-*+]|\d+\.)\s+(.+)$", stripped)
        if li_m:
            item = _clean(li_m.group(2))
            flowables.append(Paragraph(f"\u2022\u00a0{item}", st["bullet"]))
            i += 1
            continue

        # ── Paragraph (join consecutive plain lines) ────────────────────────
        parts = [stripped]
        i += 1
        while i < len(lines):
            ns = lines[i].strip()
            if not ns:
                break
            if (
                ns.startswith("#")
                or ns.startswith("|")
                or ns.startswith("```")
                or ns.startswith("!")
                or re.match(r"^([-*+]|\d+\.)\s+", ns)
            ):
                break
            parts.append(ns)
            i += 1
        flowables.append(Paragraph(_clean(" ".join(parts)), st["body"]))

    return flowables


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def export_markdown_file(markdown_file: Path, output_dir: Path) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    out_path = output_dir / f"{markdown_file.stem}.pdf"

    st = _styles()
    source_dir = markdown_file.parent

    doc = SimpleDocTemplate(
        str(out_path),
        pagesize=letter,
        leftMargin=MARGIN,
        rightMargin=MARGIN,
        topMargin=MARGIN,
        bottomMargin=MARGIN,
        title=markdown_file.stem,
    )

    text = markdown_file.read_text(encoding="utf-8")
    flowables = _to_flowables(text, source_dir, st)
    doc.build(flowables)
    return out_path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Export markdown files to PDF.")
    p.add_argument("markdown_files", nargs="+")
    p.add_argument("--output-dir", required=True)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    output_dir = Path(args.output_dir)
    for md_path in args.markdown_files:
        src = Path(md_path)
        if not src.is_file():
            raise FileNotFoundError(f"Not found: {src}")
        out = export_markdown_file(src, output_dir)
        print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
