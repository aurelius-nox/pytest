https://chatgpt.com/c/6abccc2f-85d8-83ee-a4f6-329196ad48c6

# Project 3 — CI/CD with GitHub Actions, Pytest, Ruff & GHCR

## Overview

This project demonstrates a basic CI/CD pipeline for a small Python application.

The project started as a simple Python application containing `add()` and `multiply()` functions. Instead of modifying the completed Project 2 application, a separate small project was created specifically to learn testing and CI/CD concepts.

The final pipeline automatically:

1. Checks the source code with Ruff.
2. Runs automated tests with Pytest.
3. Builds a Docker image.
4. Logs into GitHub Container Registry (GHCR).
5. Publishes the Docker image to GHCR.

The important behavior is that **later stages only run when earlier stages succeed**.

```text
git push
    ↓
GitHub Actions
    ↓
Ruff lint check
    ↓
Pytest
    ↓
Docker build
    ↓
GHCR login
    ↓
Docker push
```

If testing fails, the pipeline stops before building and publishing the Docker image.

---

# 1. Initial Python Application

The application was intentionally kept small so the focus could remain on CI/CD.

The application contains two functions:

```python
def add(a, b):
    return a + b


def multiply(a, b):
    return a * b
```

The project also prints the results when the application is run directly.

The purpose of the application itself was not complexity. It was simply a small piece of code that could be tested automatically.

---

# 2. Understanding Automated Testing

Before using Pytest, the basic idea of a test was explored manually.

The goal of a test is to verify that a function produces the expected result.

For example:

```python
assert add(1, 4) == 5
```

The important idea is:

```text
actual result == expected result
```

If the assertion is true, the test passes.

If it is false, the test fails.

For example:

```python
assert add(1, 4) == 6
```

produces a failure because:

```text
add(1, 4) → 5

5 != 6
```

This demonstrated why automated tests are useful: they can detect when code behavior differs from what is expected.

---

# 3. Why Pytest?

Instead of writing custom testing logic such as:

```python
try:
    assert ...
except:
    ...
```

Pytest provides a testing framework that automatically discovers and executes test functions.

Pytest recognizes test files and functions using naming conventions such as:

```text
test_*.py
*_test.py
```

and test functions such as:

```python
def test_add():
    ...
```

This allows tests to remain separate from the application code.

The project therefore uses a structure similar to:

```text
pytest/
├── add.py
├── requirements.txt
├── readme.md
├── tests/
│   └── test_app.py
└── .github/
    └── workflows/
        └── tests.yml
```

Keeping tests in a separate directory avoids mixing application code and test code together.

---

# 4. Virtual Environment

Initially, running:

```bash
python -m pytest
```

failed because Pytest was not installed globally.

Instead of installing project dependencies globally, a Python virtual environment was created:

```bash
python3 -m venv .venv
```

Then it was activated:

```bash
source .venv/bin/activate
```

The prompt changed to:

```text
(.venv)
```

Pytest was then installed inside the virtual environment:

```bash
pip install pytest
```

This demonstrated the purpose of a virtual environment:

- Keep project dependencies isolated.
- Avoid modifying the system Python installation.
- Allow each project to have its own dependencies.

---

# 5. Requirements File

A `requirements.txt` file was created so that project dependencies could be reproduced elsewhere.

The project eventually included:

```text
pytest
ruff
```

This is important for CI because GitHub Actions starts with a fresh environment.

The runner does not have the project's Python dependencies automatically.

Therefore the workflow can install them with:

```bash
pip install -r requirements.txt
```

---

# 6. Pytest Test Results

The tests were run with:

```bash
python -m pytest
```

A successful run looked like:

```text
collected 2 items

tests/test_app.py .. [100%]

2 passed
```

The project also intentionally introduced an error:

```python
assert add(1, 4) == 6
```

Pytest correctly reported:

```text
assert 5 == 6
```

and:

```text
1 failed, 1 passed
```

The code was then corrected and the tests returned to:

```text
2 passed
```

This demonstrated that the testing system actually detects incorrect behavior rather than simply reporting success.

---

# 7. Git Repository

The project was initialized as its own Git repository.

The repository was connected to GitHub:

```text
https://github.com/aurelius-nox/pytest
```

The main branch was named:

```text
main
```

The project was committed and pushed to GitHub.

The `.venv` directory was not committed because virtual environments should not be stored in the Git repository.

A `.gitignore` file was used to exclude unnecessary files such as Python cache files and the virtual environment.

---

# 8. GitHub Actions

The next step was automating the tests.

GitHub Actions is GitHub's automation/CI platform.

It runs workflows on GitHub-hosted machines called **runners**.

A workflow was created at:

```text
.github/workflows/tests.yml
```

The basic workflow structure is:

```yaml
name: Tests

on:
  push:

jobs:
  test:
    runs-on: ubuntu-latest

    steps: ...
```

Important concepts learned:

### Workflow

The entire automation definition.

### Job

A group of steps executed together.

### Runner

The machine/environment where the job runs.

In this project:

```yaml
runs-on: ubuntu-latest
```

means GitHub provides an Ubuntu runner.

### Step

An individual operation inside the job.

---

# 9. GitHub Actions Steps

The workflow first checks out the repository:

```yaml
- name: Checkout repository
  uses: actions/checkout@v6
```

This makes the repository's source code available on the GitHub Actions runner.

Then Python is configured:

```yaml
- name: Set up Python
  uses: actions/setup-python@v6
  with:
    python-version: "3.14"
```

Then project dependencies are installed:

```yaml
- name: Install Dependencies
  run: pip install -r requirements.txt
```

Then Ruff checks the code:

```yaml
- name: Ruff lint check
  run: ruff check .
```

Finally Pytest runs:

```yaml
- name: Run tests
  run: python -m pytest
```

The workflow therefore automatically performs the same checks that were previously being run manually.

---

# 10. Ruff

Ruff was added as a Python linter.

A linting tool checks source code for problems such as formatting issues, unused code, and other common code-quality problems.

For example, Ruff detected:

```python
from add import add , multiply
```

and suggested:

```python
from add import add, multiply
```

The important distinction learned was:

```text
Ruff → checks code quality/style
Pytest → checks program behavior
```

Both are useful CI checks.

---

# 11. CI Pipeline

At this point, the project had a basic Continuous Integration pipeline:

```text
git push
    ↓
GitHub Actions
    ↓
Checkout code
    ↓
Set up Python
    ↓
Install dependencies
    ↓
Ruff
    ↓
Pytest
```

CI means **Continuous Integration**.

The idea is that changes can be automatically checked whenever code is pushed.

Instead of waiting until later to discover that a change broke something, the automated checks provide early feedback.

---

# 12. Dockerizing the Test Project

The project was then containerized.

The Dockerfile was:

```dockerfile
FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .

COPY add.py .

COPY tests/test_app.py .

RUN pip install -r requirements.txt

CMD ["python", "-m", "pytest"]
```

The important Docker concepts were reinforced:

### Dockerfile

A set of instructions describing how to build the image.

### Image

The built, packaged artifact containing the application and its dependencies.

### Container

A running instance created from the image.

The Docker image was built locally with:

```bash
docker build -t pytest-docker .
```

Then it was tested:

```bash
docker run --name pytest-container pytest-docker
```

The container successfully ran:

```text
collected 2 items

test_app.py .. [100%]

2 passed
```

This confirmed that the tests could also run inside a container.

---

# 13. Building the Docker Image in CI

Docker was then added to the GitHub Actions workflow.

Initially the workflow built:

```yaml
- name: build docker image
  run: docker build -t pytest-docker .
```

Later, the image was built directly using its GHCR address:

```yaml
- name: build docker image
  run: docker build -t ghcr.io/aurelius-nox/pytest:latest .
```

This was important because Docker image names/tags determine where an image is intended to be published.

---

# 14. Docker Image Tags

The image was initially tagged locally as:

```text
pytest-docker
```

Then it was tagged for GitHub Container Registry:

```text
ghcr.io/aurelius-nox/pytest:latest
```

The structure is:

```text
ghcr.io
│
└── aurelius-nox
    │
    └── pytest
        │
        └── latest
```

The registry hostname is:

```text
ghcr.io
```

The GitHub account is:

```text
aurelius-nox
```

The package/image name is:

```text
pytest
```

The tag is:

```text
latest
```

---

# 15. GitHub Container Registry

GHCR stands for **GitHub Container Registry**.

It is a container image registry provided by GitHub.

The important distinction learned was:

```text
GitHub repository
    ↓
source code, tests, Dockerfile, workflows

GitHub Container Registry
    ↓
built Docker images
```

The Git repository contains the instructions/source.

The registry contains the built artifact.

---

# 16. Manual Docker Push

Before automating the Docker push, the image was manually published.

First, Docker was authenticated with GHCR:

```bash
docker login ghcr.io
```

A GitHub username was used:

```text
aurelius-nox
```

A GitHub Personal Access Token was used instead of the normal GitHub password.

After authentication:

```text
Login Succeeded
```

The image was pushed with:

```bash
docker push ghcr.io/aurelius-nox/pytest:latest
```

The registry returned a digest similar to:

```text
latest: digest: sha256:...
```

This demonstrated the difference between:

```text
docker tag
```

and:

```text
docker push
```

`docker tag` gives an image a registry-oriented name.

`docker push` actually uploads the image to the registry.

---

# 17. GitHub Actions → GHCR

The final goal was to make GitHub Actions publish the Docker image automatically.

The workflow was given package permissions:

```yaml
permissions:
  contents: read
  packages: write
```

This means the workflow can:

```text
contents: read
→ read the repository

packages: write
→ publish packages/images
```

---

# 18. GITHUB_TOKEN

GitHub automatically provides a temporary `GITHUB_TOKEN` to Actions workflows.

The workflow uses it instead of storing a personal GitHub password or Personal Access Token in the repository.

The workflow authenticates Docker with:

```yaml
- name: Log in to GHCR
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

Important concepts:

### `github.actor`

The GitHub account that triggered the workflow run.

### `secrets.GITHUB_TOKEN`

A temporary authentication token automatically provided to the workflow.

### `docker/login-action`

A reusable GitHub Action that performs Docker registry authentication.

---

# 19. Publishing the Image

After authentication, the workflow pushes the image:

```yaml
- name: Push Docker image
  run: docker push ghcr.io/aurelius-nox/pytest:latest
```

The complete final workflow is:

```yaml
name: Tests

on:
  push:

permissions:
  contents: read
  packages: write

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v6

      - name: Set up Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.14"

      - name: Install Dependencies
        run: pip install -r requirements.txt

      - name: Ruff lint check
        run: ruff check .

      - name: Run tests
        run: python -m pytest

      - name: build docker image
        run: docker build -t ghcr.io/aurelius-nox/pytest:latest .

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Push Docker image
        run: docker push ghcr.io/aurelius-nox/pytest:latest
```

---

# 20. Authentication vs Authorization

During the project, the automated push initially failed even though login succeeded.

The important error was:

```text
denied: permission_denied: write_package
```

The workflow successfully authenticated:

```text
Login Succeeded!
```

but was not authorized to write to the existing GHCR package.

This demonstrated an important security concept:

```text
Authentication
→ Who are you?

Authorization
→ What are you allowed to do?
```

The package's Actions access was configured to allow the repository's workflow to write to the package.

After that permission was corrected, the workflow successfully pushed the image.

---

# 21. CI/CD Failure Gate

The most important experiment was deliberately introducing an incorrect test.

The pipeline then behaved like this:

```text
Checkout          ✅
Python setup      ✅
Dependencies      ✅
Ruff              ✅
Pytest            ❌
Docker build      ⛔
GHCR login        ⛔
Docker push       ⛔
```

After correcting the code:

```text
Checkout          ✅
Python setup      ✅
Dependencies      ✅
Ruff              ✅
Pytest            ✅
Docker build      ✅
GHCR login        ✅
Docker push       ✅
```

This proved that the pipeline acts as a **gate**.

If the quality checks fail, later deployment/publishing steps do not proceed.

---

# 22. Final CI/CD Architecture

The final project flow is:

```text
Developer
   │
   │ git push
   ▼
GitHub Repository
   │
   ▼
GitHub Actions Runner
   │
   ├── Checkout repository
   │
   ├── Set up Python
   │
   ├── Install dependencies
   │
   ├── Ruff lint check
   │
   ├── Pytest
   │       │
   │       └── failure → STOP
   │
   ├── Docker build
   │
   ├── Authenticate with GHCR
   │
   └── Docker push
   │
   ▼
GitHub Container Registry
   │
   └── ghcr.io/aurelius-nox/pytest:latest
```

---

# 23. Main Concepts Learned

### Continuous Integration (CI)

Automatically checking code changes through processes such as:

- linting
- automated testing
- dependency installation
- build verification

The purpose is to detect problems early.

### Continuous Deployment / Delivery (CD)

Automatically moving a validated artifact toward its deployment/distribution destination.

In this project, the validated Docker image is automatically published to GHCR.

### GitHub Actions

GitHub's automation system used to execute the CI/CD workflow.

### Runner

The machine provided by GitHub that executes the workflow.

### Workflow

The YAML file defining the automation.

### Job

A collection of steps executed on a runner.

### Step

An individual action or shell command.

### Pytest

Automated Python testing framework.

### Ruff

Python linting/code-quality tool.

### Dockerfile

Instructions used to build a Docker image.

### Docker Image

A packaged, immutable artifact used as the basis for containers.

### Docker Container

A running instance of a Docker image.

### Registry

A service that stores and distributes container images.

### GHCR

GitHub Container Registry.

### GITHUB_TOKEN

Temporary authentication token automatically provided to GitHub Actions.

### Permissions

Controls what the workflow's token is allowed to do.

### Authentication

Proves the identity of the requester.

### Authorization

Determines what that authenticated requester is allowed to access or modify.

---

# 24. Final Outcome

The project successfully demonstrates a complete basic CI/CD pipeline:

```text
Code
 ↓
Git push
 ↓
GitHub Actions
 ↓
Lint
 ↓
Automated tests
 ↓
Docker build
 ↓
GHCR authentication
 ↓
Docker image publication
```

The project also demonstrates that a failed quality check prevents the Docker image from being built and published.

This project therefore connects the previously learned concepts of:

```text
Git
GitHub
Python
Testing
Linux
Docker
Containers
Registries
Automation
CI/CD
```

into one automated workflow.
