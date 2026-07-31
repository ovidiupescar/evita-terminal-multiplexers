import pytest
from pathlib import Path


FILES_TO_CHECK = [
    "README.md",
    "CITATION.cff",
    "pyproject.toml",
    "content/index.md",
    "content/conf.py",
    "content/instructor-guide.md",
    "content/reference-for-learners.md",
]


def find_fixmes(filepath):
    """Find all FIXME occurrences in a file with line numbers."""
    fixmes = []
    try:
        content = Path(filepath).read_text(encoding="utf-8")
        for line_num, line in enumerate(content.splitlines(), start=1):
            if "FIXME" in line:
                fixmes.append((line_num, line.strip()))
    except FileNotFoundError:
        pass
    return fixmes


@pytest.mark.parametrize("filepath", FILES_TO_CHECK)
def test_no_fixme_in_file(filepath):
    """Test that a file has no FIXME comments.

    Collects and displays all FIXME occurrences with line numbers.
    """
    fixmes = find_fixmes(filepath)

    if fixmes:
        error_msg = f"FIXME comments found in {filepath}:\n"
        for line_num, line in fixmes:
            error_msg += f"  Line {line_num}: {line}\n"
        print(error_msg)

    fixme_count = len(fixmes)
    assert fixme_count == 0, f"{fixme_count} {error_msg}"
