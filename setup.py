from distutils.core import setup
from Cython.Build import cythonize
setup(ext_modules = cythonize("*.pyx"),
	name='solargeo',
	author="Karl Lapo",
	author_email="lapok@atmos.washington.edu",
	description="""Solar geometry parameters""",
	packages=['solargeo'],
)
