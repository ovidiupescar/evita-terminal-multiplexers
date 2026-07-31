import nox

@nox.session(python=None)
def tests(session):
    session.install("pytest", "cffconvert>=2.0.0", "pykwalify>=1.8.0")
    session.run("pytest")
