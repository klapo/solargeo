from setuptools import setup
from Cython.Build import cythonize

setup(
    name='solargeo',
    author='Karl Lapo',
    author_email='lapok@atmos.washington.edu',
    description='Solar geometry parameters -- compiled c code',
    packages=['solargeo'],
    version='0.2',
    ext_modules=cythonize('solargeo/*.pyx'),
    install_requires=['pandas', 'Cython', 'numpy'],
    tests_require=['pytest', 'engarde'])
