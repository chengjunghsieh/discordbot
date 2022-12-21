# Pipenv Usage

Python version >= 3.8

## Install Pipenv

```
pip3 install pipenv
```

## Installation

```
pipenv install
```

### Install Package

```
pipenv install <package>
```
this command will update Pipfile.

```
pipenv install <package> --dev
```
this comamnd will only install package in `dev` env.

#### Lock Enviroment

```
pipenv lock
```
this command will write current enviroment dependencies to Pipfile.lock.


## Usage

use pipenv shell

```
pipenv shell
```

or

```
pipenv python3 <file>
```
