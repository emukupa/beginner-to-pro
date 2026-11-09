// The bar chart. It writes through the function it's given: console.log in main, an array in a test.

import type { Pair } from "./tasklist.ts";
import { roundHalfEven } from "./text.ts";

export const CHART_WIDTH = 20; // the longest bar, in characters
const BAR = "█";

export function drawChart(pairs: readonly Pair[], print: (line: string) => void = console.log, width = CHART_WIDTH): void {
  const first = pairs[0]; // Pair | undefined: noUncheckedIndexedAccess makes us check
  if (!first) {
    print("No tags yet.");
    return;
  }
  const length = (s: string) => [...s].length; // characters, not UTF-16 code units
  const labelWidth = Math.max(...pairs.map(([tag]) => length(tag)));
  for (const [tag, count] of pairs) {
    const bar = BAR.repeat(roundHalfEven((count / first[1]) * width));
    print(`${tag}${" ".repeat(labelWidth - length(tag))}  ${bar} ${count}`);
  }
}
