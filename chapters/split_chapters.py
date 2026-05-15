from __future__ import annotations

import argparse
import re
from pathlib import Path

from pypdf import PdfReader, PdfWriter


DEFAULT_INPUT = "鲁郁 - 2016 - 北斗GPS双模软件接收机原理与实现技术.pdf"
DEFAULT_OUTPUT_DIR = "chapters"
CHAPTER_TITLE_RE = re.compile(r"^第\s*([0-9一二三四五六七八九]+)\s*章\s*(.+)$")
CHINESE_NUMBERS = {
    "一": 1,
    "二": 2,
    "三": 3,
    "四": 4,
    "五": 5,
    "六": 6,
    "七": 7,
    "八": 8,
    "九": 9,
}
BAD_FILENAME_CHARS = re.compile(r'[\\/:*?"<>|]')


def chapter_number(text: str) -> int:
    if text.isdigit():
        return int(text)
    if text in CHINESE_NUMBERS:
        return CHINESE_NUMBERS[text]
    raise ValueError(f"unsupported chapter number: {text}")


def clean_title(title: str) -> str:
    return title.replace("\x00", "").strip()


def safe_filename(title: str) -> str:
    title = BAD_FILENAME_CHARS.sub("_", title)
    title = re.sub(r"\s+", " ", title).strip()
    return title.rstrip(". ")


def iter_top_level_outline(reader: PdfReader):
    for item in reader.outline:
        if isinstance(item, list):
            continue
        title = clean_title(getattr(item, "title", str(item)))
        page_index = reader.get_destination_page_number(item)
        yield title, page_index


def find_chapter_ranges(reader: PdfReader, first: int, last: int):
    top_level = list(iter_top_level_outline(reader))
    chapters = []

    for index, (title, page_index) in enumerate(top_level):
        match = CHAPTER_TITLE_RE.match(title)
        if not match:
            continue

        number = chapter_number(match.group(1))
        if first <= number <= last:
            chapters.append(
                {
                    "number": number,
                    "title": title,
                    "short_title": match.group(2).strip(),
                    "start": page_index,
                    "outline_index": index,
                }
            )

    found = {chapter["number"] for chapter in chapters}
    missing = [number for number in range(first, last + 1) if number not in found]
    if missing:
        missing_text = ", ".join(f"第{number}章" for number in missing)
        raise RuntimeError(f"PDF 顶层书签中未找到: {missing_text}")

    chapters.sort(key=lambda chapter: chapter["number"])

    for chapter in chapters:
        next_top_level = top_level[chapter["outline_index"] + 1 :]
        if not next_top_level:
            chapter["end"] = len(reader.pages)
        else:
            chapter["end"] = next_top_level[0][1]

    return chapters


def split_chapters(
    input_pdf: Path,
    output_dir: Path,
    first_chapter: int,
    last_chapter: int,
    overwrite: bool,
) -> list[Path]:
    reader = PdfReader(str(input_pdf))
    chapters = find_chapter_ranges(reader, first_chapter, last_chapter)
    output_dir.mkdir(parents=True, exist_ok=True)

    written: list[Path] = []
    for chapter in chapters:
        number = chapter["number"]
        title = chapter["title"]
        short_title = chapter["short_title"]
        start = chapter["start"]
        end = chapter["end"]
        output_pdf = output_dir / f"第{number:02d}章_{safe_filename(short_title)}.pdf"

        if output_pdf.exists() and not overwrite:
            raise FileExistsError(f"{output_pdf} 已存在；如需覆盖请加 --overwrite")

        writer = PdfWriter()
        for page_index in range(start, end):
            writer.add_page(reader.pages[page_index])

        writer.add_metadata(
            {
                "/Title": title,
                "/Source": input_pdf.name,
            }
        )

        with output_pdf.open("wb") as file:
            writer.write(file)

        written.append(output_pdf)
        print(
            f"{output_pdf}  <-  PDF页码 {start + 1}-{end}，共 {end - start} 页"
        )

    return written


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="按 PDF 顶层书签自动拆分第 1 章到第 9 章。"
    )
    parser.add_argument(
        "-i",
        "--input",
        default=DEFAULT_INPUT,
        type=Path,
        help=f"源 PDF，默认: {DEFAULT_INPUT}",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default=DEFAULT_OUTPUT_DIR,
        type=Path,
        help=f"输出目录，默认: {DEFAULT_OUTPUT_DIR}",
    )
    parser.add_argument("--first-chapter", type=int, default=1)
    parser.add_argument("--last-chapter", type=int, default=9)
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="允许覆盖已存在的拆分 PDF。",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    split_chapters(
        input_pdf=args.input,
        output_dir=args.output_dir,
        first_chapter=args.first_chapter,
        last_chapter=args.last_chapter,
        overwrite=args.overwrite,
    )


if __name__ == "__main__":
    main()
