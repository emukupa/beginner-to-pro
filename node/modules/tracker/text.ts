// Python's whitespace rules, shared by parsing and the command line.

// Exactly what Python's str.split() and str.strip() treat as space. JavaScript's \s is almost the
// same, but not quite (it has ﻿, and lacks \x85 and \x1c-\x1f).
const SPACE = "\\t\\n\\v\\f\\r\\x1c-\\x1f \\x85\\xa0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000";
const EDGE_SPACE = new RegExp(`^[${SPACE}]+|[${SPACE}]+$`, "g");
const RUN_OF_SPACE = new RegExp(`[${SPACE}]+`);

export const strip = (s: string): string => s.replace(EDGE_SPACE, "");
export const words = (s: string): string[] => strip(s).split(RUN_OF_SPACE).filter((w) => w !== "");

// Python's round(): halves go to the even neighbour. Math.round and toFixed both send halves up.
export function roundHalfEven(x: number): number {
  const floor = Math.floor(x);
  if (x - floor !== 0.5) return Math.round(x);
  return floor % 2 === 0 ? floor : floor + 1;
}
