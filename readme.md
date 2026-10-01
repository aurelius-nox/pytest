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
