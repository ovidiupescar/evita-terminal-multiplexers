import subprocess
import sys


def test_cff_validation():
    """Test that CITATION.cff is valid using cffconvert --validate."""
    result = subprocess.run(
        ["cffconvert", "--validate"],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, f"CFF validation failed. {result.stderr}"
