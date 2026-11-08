"""Drawing the tag chart. Knows nothing about tasks: it takes (label, count) pairs."""


def draw_chart(pairs, width=20, char="█"):
    if not pairs:
        print("No tags yet.")
        return
    biggest = pairs[0][1]
    label_width = max(len(tag) for tag, _ in pairs)
    for tag, count in pairs:
        bar = char * round(count / biggest * width)
        print(f"{tag:<{label_width}}  {bar} {count}")
