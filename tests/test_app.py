from add import add, multiply


def test_add():
    a = 1
    b = 4
    assert add(a,b) == 6

def test_multiply():
    a = 2
    b = 3
    assert multiply(a, b) == 6