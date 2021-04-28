from setuptools import setup, find_packages

setup(
	name='inference-server',
	version='42',
	py_modules=["inference_server", "inference_cli"],
	python_requires='>=3.6, <4',
	install_requires=[],
)
