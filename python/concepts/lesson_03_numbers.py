"""Numbers, and turning text into numbers."""
TITLE = "Numbers and input"


def run():
    print("3 + 4, 3 - 4, 3 * 4, 3 / 4 ->", (3 + 4, 3 - 4, 3 * 4, 3 / 4))
    print("2 ** 10 ->", 2 ** 10, "  7 // 2 ->", 7 // 2, "  7 % 2 ->", 7 % 2)
    print("0.1 + 0.2 ->", 0.1 + 0.2)                 # floats are binary fractions: close, not exact
    print("round(2.5), round(3.5) ->", round(2.5), round(3.5))  # halves go to the even number
    print(f"12.5 shown with no decimals -> {12.5:.0f}")

    answer = input("How many top tags? ")           # input always gives you text
    print("you typed", repr(answer), "which is a", type(answer).__name__)
    try:
        n = int(answer)                              # int() turns text into a whole number...
        print("as a number:", n, "doubled:", n * 2)
    except ValueError:
        print("int() couldn't read", repr(answer), "as a whole number")  # ...or refuses
