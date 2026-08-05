import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { createRequire } from "node:module";
import { Marked } from "marked";
import { gfmHeadingId } from "marked-gfm-heading-id";

const require = createRequire(import.meta.url);
const __dirname = dirname(fileURLToPath(import.meta.url));

// The profile README lives at <repo-root>/profile/README.md.
// This script lives at <repo-root>/.cursor/preview/server.mjs.
const REPO_ROOT = resolve(__dirname, "..", "..");
const README_PATH = resolve(REPO_ROOT, "profile", "README.md");
const CSS_PATH = require.resolve("github-markdown-css/github-markdown.css");

const HOST = process.env.HOST ?? "0.0.0.0";
const PORT = Number(process.env.PORT ?? 3000);

const marked = new Marked({ gfm: true, breaks: false });
marked.use(gfmHeadingId());

function page(bodyHtml, css) {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Whop org profile preview</title>
<style>
${css}
body { margin: 0; background: #f6f8fa; }
.markdown-body {
  box-sizing: border-box;
  max-width: 900px;
  margin: 32px auto;
  padding: 45px;
  background: #ffffff;
  border: 1px solid #d0d7de;
  border-radius: 6px;
}
</style>
</head>
<body>
<article class="markdown-body">
${bodyHtml}
</article>
</body>
</html>`;
}

const server = createServer(async (req, res) => {
  try {
    if (req.url === "/healthz") {
      res.writeHead(200, { "content-type": "text/plain" });
      res.end("ok");
      return;
    }

    // Re-read on every request so edits to profile/README.md show up on refresh.
    const [markdown, css] = await Promise.all([
      readFile(README_PATH, "utf8"),
      readFile(CSS_PATH, "utf8"),
    ]);
    const bodyHtml = marked.parse(markdown);
    res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
    res.end(page(bodyHtml, css));
  } catch (err) {
    res.writeHead(500, { "content-type": "text/plain" });
    res.end(`Failed to render profile README: ${err.message}`);
  }
});

server.listen(PORT, HOST, () => {
  console.log(`Whop profile preview rendering ${README_PATH}`);
  console.log(`Listening on http://${HOST}:${PORT}`);
});
