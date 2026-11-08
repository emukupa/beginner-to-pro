// npm run bug -- 7: type-checks bugs/lesson_07.ts on its own, with the project's own tsconfig rules,
// so tsc's error for that lesson's deliberate mistake is all you see. It's TypeScript's BUG=1:
// the mistake is caught before anything runs. (`node concepts/bugs/lesson_07.ts` runs it unchecked,
// to see what Node does without tsc: type stripping deletes the types and never looks at them.)
//
// tsc can't take a file and a tsconfig.json together, so this writes a tiny tsconfig that extends
// the real one and lists just the one file, in a temporary folder, then runs tsc on it.

import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const here = import.meta.dirname;
const root = join(here, "..", "..");
const available = readdirSync(here).filter((name) => /^lesson_\d\d\.ts$/.test(name)).sort();
const number = Number(process.argv[2]);
const file = join(here, `lesson_${String(number).padStart(2, "0")}.ts`);

if (!Number.isInteger(number) || !existsSync(file)) {
    console.error(`Usage: npm run bug -- N, where N is one of: ${available.map((name) => Number(name.slice(7, 9))).join(" ")}`);
    process.exit(2);
}

const folder = mkdtempSync(join(tmpdir(), "concepts-bug-"));
const config = join(folder, "tsconfig.json");
// typeRoots: type packages are looked for beside the tsconfig, so point back at node/node_modules.
const compilerOptions = { typeRoots: [join(root, "node_modules", "@types")] };
writeFileSync(config, JSON.stringify({ extends: join(root, "tsconfig.json"), compilerOptions, include: [], files: [file] }));
console.log(`tsc on concepts/bugs/lesson_${String(number).padStart(2, "0")}.ts: this should fail`);
// --pretty: colours, and the offending line with the mistake underlined, even through a pipe.
const tsc = spawnSync(join(root, "node_modules", ".bin", "tsc"), ["--noEmit", "--pretty", "-p", config], {
    cwd: root,
    encoding: "utf8",
});
rmSync(folder, { recursive: true });
// Paths come out relative to the temporary folder; show them relative to node/ instead.
process.stdout.write((tsc.stdout ?? "").replaceAll(/(\.\.\/)+.*?concepts\/bugs\//g, "concepts/bugs/"));
if (tsc.status === 0) {
    console.error("tsc found nothing: the bug wasn't caught");
    process.exit(1);
}
process.exit(tsc.status ?? 1);
