https://chatgpt.com/c/6abccc2f-85d8-83ee-a4f6-329196ad48c6

# Phase 1: Building Our First CI Pipeline Milestone

We have successfully established the foundational piece of our **Continuous Integration (CI) pipeline** by setting up an isolated local environment and running automated tests.

---

## 🛠️ The CI Workflow Completed

1. **Create** a virtual environment (`.venv`).
2. **Activate** the environment (isolating dependencies from the global Fedora OS).
3. **Install** `pytest` locally.
4. **Execute** `python -m pytest` to trigger automatic test discovery.
5. **Run & Pass** 2 automatically discovered tests (e.g., `add` and `multiply`) successfully.

> 💡 **Note on Dependencies:** The system prefix `(.venv)` confirms that `pytest` lives safely inside this project folder rather than globally. You can safely ignore `pip` upgrade warnings for now.

---

## 📂 Project Structure

Our project layout is organized as follows:

```text
pytest/
├── app.py
├── tests/
│   └── test_app.py
└── .venv/
```

---

## 🧠 Core Concept: The Declarative Paradigm Shift

The most important takeaway from this setup is the **mental shift in how we write tests**.

Instead of traditional manual scripting, we do **not** have to:

- Write `print("PASSED")` statements.
- Wrap code in boilerplate `try/except` blocks.
- Manually invoke functions like `test_add()`.

### How Pytest Automates Execution:

1. Scan for files named `test_*.py` (finds `test_app.py`).
2. Identify functions starting with `test_*` (finds `test_add()`).
3. Evaluate assertions natively (e.g., `assert 5 == 5`).
4. Output a clean `PASS` or `FAIL` report.

You simply **describe what should be true**, and the testing framework handles execution and reporting.

---

## 🛑 Next Step: Deliberate Failure (CI Emulation)

To truly understand how automated testing guards a CI pipeline, we must observe how it reacts to broken code.

### 1. Modifying the Code

Open `tests/test_app.py` and deliberately break an expectation (e.g., changing the expected outcome of `2 + 3` to `6`):

```python
from app import add, multiply

def test_add():
    # Deliberately broken for demonstration
    assert add(2, 3) == 6

def test_multiply():
    assert multiply(2, 3) == 6
```

### 2. Running the Broken Build

Execute the suite in the terminal:

```bash
python -m pytest
```

### 3. Expected Failure Output

Pytest captures the failure, provides a detailed diff, and flags the build as failed. **Do not fix the code yet.** Observe the details below:

```text
============================= test session starts =============================
collected 2 items

tests/test_app.py F.                                                     [100%]

================================== FAILURES ===================================
__________________________________ test_add ___________________________________

    def test_add():
>       assert add(2, 3) == 6
E       assert 5 == 6
E        +  where 5 = add(2, 3)

tests/test_app.py:5: AssertionError
=========================== short test summary info ===========================
FAILED tests/test_app.py::test_add - assert 5 == 6
========================= 1 failed, 1 passed in 0.05s =========================
```

GITHub action

YOUR FEDORA MACHINE

pytest/
│
├── add.py
├── tests/
└── .git/
│
│ git push
↓
GITHUB
│
│ detects workflow
↓
GITHUB ACTIONS GitHub Actions = automation/orchestration system.
│
↓
RUNNER Runner = the machine that actually executes the commands.
│
↓
pytest
│
┌─┴─┐
↓ ↓
✅ ❌

github action : "When code is pushed, create an environment, install our dependencies, and run pytest."
Workflow
│
├── When should I run?
│
├── What machine should run it?
│
└── What commands should it execute?

WHEN?
↓
push to GitHub

MACHINE?
↓
GitHub-hosted runner

DO:
↓
get repository
↓
setup Python
↓
install requirements
↓
run pytest

pytest/
├── .github/
│ └── workflows/
│ └── tests.yml
├── add.py
├── tests/
├── requirements.txt
└── ...

in yml file:
git push
│
▼
GitHub Actions
│
▼
Ubuntu runner
│
┌─────────┴─────────┐
▼ ▼
Checkout repository Set up Python
│
▼
Install dependencies
│
▼
Run pytest
│
┌──────┴──────┐
▼ ▼
✅ ❌
passed failed

Linting

Tests ask:

"Does the program behave correctly?"

Linting asks more like:

"Does the code follow certain code-quality/style rules and contain suspicious patterns?"

             push
               ↓
        GitHub Actions
               ↓
        ┌──────┴──────┐
        ↓             ↓
      pytest         ruff (lint)
        ↓             ↓
        └──────┬──────┘
               ↓
             result

pytest
→ "Does the code behave as expected?"

Ruff
→ "Does the code satisfy lint/style checks?"

GitHub Actions
→ "Automatically run these checks when something happens."

Runner
→ "The machine that actually executes them."

requirements.txt
→ tells the environment what Python packages it needs

NOW CD

make docker file
docker build -t pytest-docker .
change yml to make github actions read build

Container Registry
GitHub repository
→ stores source code

Container registry
→ stores container images

Right now our image is: pytest-docker:latest
A registry needs to know where the image belongs.
For GitHub Container Registry, the image name follows this general structure: ghcr.io/OWNER/IMAGE:TAG
For your repository, that could be conceptually: ghcr.io/aurelius-nox/pytest:latest

ghcr.io
↓
GitHub Container Registry

aurelius-nox
↓
your GitHub account

pytest
↓
image/repository name

latest
↓
image tag/version

credentials in CI (who is allowd to push in ghcr)
GitHub Actions
│
│ secret/token
↓
GHCR
│
│ authenticated push
↓
Docker image stored

login:
docker login ghcr.io
Username: aurelius-nox

Then at:
Password:
do not enter your GitHub password. For GHCR command-line authentication, GitHub currently requires a Personal Access Token (classic) with the write:packages scope for pushing images.

If you don't have such a token yet:

Open GitHub's Personal access tokens → Tokens (classic) page.
Create a token.
Give it the write:packages scope. GitHub notes that the UI may also select repo; their docs recommend avoiding that broader permission when possible.
Copy the token immediately—GitHub only shows it when created.
Paste that token at the Docker Password: prompt.

docker push ghcr.io/aurelius-nox/pytest:latest >push them

now, wehave
GitHub repository
└── source code + tests + workflow

GHCR
└── Docker image
└── pytest:latest

login on yml>

- name: Log in to GHCR
  uses: docker/login-action@v3
  with:
  registry: ghcr.io
  username: ${{ github.actor }}
  password: ${{ secrets.GITHUB_TOKEN }}

git push
↓
GitHub Actions starts
↓
Checkout repository
↓
Set up Python
↓
Install dependencies
↓
Ruff lint
↓
pytest
↓
Docker build
↓
Login to GHCR
↓
Push image

                    git push
                       │
                       ▼
              GitHub Actions starts
                       │
                       ▼
              Checkout repository
                       │
                       ▼
                 Setup Python
                       │
                       ▼
              Install dependencies
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
         Ruff lint            Pytest
             │                   │
             └─────────┬─────────┘
                       ▼
                Docker build
                       │
                       ▼
                 Login to GHCR
                       │
                       ▼
              Push Docker image
                       │
                       ▼
          ghcr.io/aurelius-nox/pytest

CI: every push automatically checks the code.

CD: after the checks pass, the Docker image is automatically published.
