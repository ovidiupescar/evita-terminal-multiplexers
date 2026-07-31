# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#

# -- Project information -----------------------------------------------------

project = "Terminal multiplexers (SDS.OSV1-USE1.7)"
author = "Ovidiu Pescar, Fisherman Engineering"
copyright = f"2026, EVITA project and {author}"

git_forge = "github.com"
git_user = "ovidiupescar"
git_repo_name = "evita-terminal-multiplexers"
git_version = "main"
conf_py_path = "content"

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx_lesson",
    "sphinx_evita",
    "sphinxcontrib.bibtex",
    "myst_nb",
    "sphinx.ext.todo",
    "sphinx.ext.intersphinx",
]

if git_forge == "github.com":
    # githubpages just adds a .nojekyll file
    extensions.append("sphinx.ext.githubpages")

bibtex_bibfiles = []

# Settings for myst_nb:
# https://myst-nb.readthedocs.io/en/latest/use/execute.html#triggering-notebook-execution
# nb_execution_mode = "off"
# nb_execution_mode = "auto"   # *only* execute if at least one output is missing.
# nb_execution_mode = "force"
nb_execution_mode = "cache"

# https://myst-parser.readthedocs.io/en/latest/syntax/optional.html
myst_enable_extensions = ["colon_fence", "attrs_inline", "substitution"]
myst_substitutions = {"author": author, "copyright": copyright}

# Settings for sphinx-copybutton
copybutton_exclude = ".linenos, .gp"

# Add any paths that contain templates here, relative to this directory.
# templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
    "README*",
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "jupyter_execute",
    "*venv*",
]

# -- Options for HTML output -------------------------------------------------
from pathlib import Path
from sphinx_evita import icons


# Auto-detect directory name. This can break, but useful as a default.
HERE = Path(__file__).parent
detected_repo_name = HERE.parent.name

git_repo_url = f"https://{git_forge}/{git_user}/{git_repo_name or detected_repo_name}"


# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_title = project
# NOTE: the html_theme is automatically configured by sphinx-evita
# html_theme = "furo"

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ["_static"]
# html_css_files = ["overrides.css"]

# Some theme options such as logo are defined by sphinx-evita extensions
html_theme_options = {
    # Gitlab
    "source_edit_link": f"{git_repo_url}/-/edit/{git_version}/{conf_py_path}/{{filename}}",
    "source_view_link": f"{git_repo_url}/-/blob/{git_version}/{conf_py_path}/{{filename}}?plain=1",
    # Github
    # "source_repository": git_repo_url,
    # "source_branch": git_version,
    # "source_directory": conf_py_path,
    "footer_icons": [
        {
            "name": git_forge,
            "url": git_repo_url,
            "html": icons.github if git_forge == "github.com" else icons.gitlab, 
            "class": "",
        },
    ],
}


# HTML context:
html_context = {
    "git_user": git_user,
    "git_repo": git_repo_name or detected_repo_name,
    "git_version": git_version,
    "conf_py_path": conf_py_path,
}

# do not have any external links to documentations which use Sphinx

# Intersphinx mapping.  For example, with this you can use
#   <inv:python:mod#multiprocessing> or [some text](inv:python:mod#multiprocessing)
# to link straight to the Python docs of that module.
# List all available references:
#   python -msphinx.ext.intersphinx https://docs.python.org/3/objects.inv
#
intersphinx_mapping = {
    # "python": ("https://docs.python.org/3", None),
    # "sphinx": ("https://www.sphinx-doc.org/", None),
    # "numpy": ("https://numpy.org/doc/stable/", None),
    # "scipy": ("https://docs.scipy.org/doc/scipy/reference/", None),
    # "pandas": ("https://pandas.pydata.org/docs/", None),
    # "matplotlib": ("https://matplotlib.org/", None),
    # "seaborn": ("https://seaborn.pydata.org/", None),
    # "evita": ("https://sphinx-evita.readthedocs.io/en/latest", None),
    # "instruct": ("https://enccs.github.io/instructor-training/", None),
    # "lesson": ("https://coderefinery.github.io/sphinx-lesson/", None),
    # "myst": ("https://myst-parser.readthedocs.io/en/latest/", None),
}

intersphinx_timeout = 3

# Settings for sphinx_pyppeteer_builder (PDF generation)
# Required for running Chromium in Docker containers
pyppeteer_pdf_options = {
    "headless": True,
    "args": [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
    ]
}
