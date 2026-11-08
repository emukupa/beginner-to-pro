# TypeScript on Node

The task tracker in TypeScript, run directly by Node: Node strips the types and runs what's left, so
there's no build step, and `tsc` checks the types separately with strict settings. Needs Node 24+
(type stripping is on by default there) and npm. The only dependencies are for checking:
`typescript` (`tsc`) and `@types/node` (the types of Node's own modules).

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one ES module per concept, run by `main.ts`: `npm run concepts` runs them all, `node concepts/main.ts 7` one, `npm run bug -- 7` type-checks its mistake | 00 |

```bash
cd node
npm install          # once: typescript and @types/node, into node_modules/
npm run concepts     # every lesson
npm run check        # tsc --noEmit: the type check, strict
npm test             # node --test
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/node/00-concepts/start` | `course/node/00-concepts/end` | `video/node-000` |

VS Code understands TypeScript out of the box; it reads `tsconfig.json`, so the editor shows the
same errors as `npm run check`.
