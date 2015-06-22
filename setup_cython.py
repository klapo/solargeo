#from distutils.core import setup
#from Cython.Build import cythonize
#from distutils.extension import Extension

#setup(ext_modules = cythonize("solargeo/*.pyx"),
#	name='solargeo',
#	author="Karl Lapo",
#	author_email="lapok@atmos.washington.edu",
#	description="""Solar geometry parameters""",
#	ext_modules=[Extension('solargeo.SUNAE',
#	   sources=['solargeo/SUNAE.c'])])

# Setup.py from http://stackoverflow.com/questions/4505747/how-should-i-structure-a-python-package-that-contains-cython-code

# Check out netcdf4 github (NCAR unidata) for example of successful setup.py

from distutils.core import setup
from distutils.extension import Extension

try:
	from Cython.Distutils import build_ext
except ImportError:
	use_cython = False
else:
	use_cython = True

cmdclass = { }
ext_modules = [ ]

if use_cython:
	ext_modules += [
		Extension("solargeocee.SUNAE", [ "solargeocee/SUNAE.pyx" ]),
		Extension("solargeocee.AVG_EL", [ "solargeocee/AVG_EL.pyx" ]),
	]
	cmdclass.update({ 'build_ext': build_ext })

else:
	ext_modules += [
		Extension("solargeocee.SUNAE", [ "solargeocee/SUNAE.c" ]),
		Extension("solargeocee.AVG_EL", [ "solargeocee/AVG_EL.c" ]),
	]

setup(
	name='solargeocee',
	author="Karl Lapo",
	author_email="lapok@atmos.washington.edu",
	description="""Solar geometry parameters -- compiled c code""",
	package_dir = 'solargeocee',
	packages=['solarrgeocee'],
	version='0.2',
	cmdclass = cmdclass,
	ext_modules=ext_modules,
)

