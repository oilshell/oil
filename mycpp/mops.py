"""
Math operations, e.g. for arbitrary precision integers 

They are currently int64_t, rather than C int, but we want to upgrade to
heap-allocated integers.
"""
from __future__ import print_function

# Rename:
#
# mops.big_add()
# mops.big_lshift()
#
# mops.float_add()
#
# Regular int ops can use the normal operators, or maybe i_add() if we really
# want.  That probably slows down code gen.

# I suppose float ops could too, but it feels nicer to develop a formal
# interface?


class BigInt(int):
    """In Python, all integers are big.  In C++, only some are."""
    pass


def BigIntStr(b):
    # type: (BigInt) -> str
    return str(b)


def BigIntToSmall(b):
    # type: (BigInt) -> int
    return b


def SmallIntToBig(b):
    # type: (int) -> BigInt
    return b


def ToBigInt(s, base=10):
    # type: (str, int) -> BigInt
    return BigInt(s, base)  # like int(s, base)


# Can't use operator overloading


def Add(a, b):
    # type: (BigInt, BigInt) -> BigInt
    return a + b


def Subtract(a, b):
    # type: (BigInt, BigInt) -> BigInt
    return a - b


def Multiply(a, b):
    # type: (BigInt, BigInt) -> BigInt
    return a * b


# Question: does Oils behave like C remainder when it's positive?
# Then we could be more efficient I think


def PositiveDiv(a, b):
    # type: (BigInt, BigInt) -> BigInt
    assert a >= 0 and b >= 0, (a, b)
    return a // b


def PositiveMod(a, b):
    # type: (BigInt, BigInt) -> BigInt
    assert a >= 0 and b >= 0, (a, b)
    return a % b


def ShiftLeft(a, b):
    # type: (BigInt, BigInt) -> BigInt
    return a << b


def ShiftRight(a, b):
    # type: (BigInt, BigInt) -> BigInt
    return a >> b
