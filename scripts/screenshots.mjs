// Screenshots each changed post at desktop (1440 px) and as an iPhone 15,
// and fails if the iPhone page scrolls sideways.
// Usage: node scripts/screenshots.mjs <base-url> <out-dir> <post .md files...>
import puppeteer, { KnownDevices } from "puppeteer";
import fs from "node:fs";
import path from "node:path";

const [base, outDir, ...posts] = process.argv.slice(2);
fs.mkdirSync(outDir, { recursive: true });
const browser = await puppeteer.launch({ args: ["--no-sandbox"] });
const failures = [];

for (const post of posts) {
  const urlPath = post.replace(/^Content\//, "/").replace(/\.md$/, "/");
  const name = path.basename(post, ".md");
  const page = await browser.newPage();

  await page.setViewport({ width: 1440, height: 900 });
  await page.goto(base + urlPath, { waitUntil: "networkidle0" });
  await page.screenshot({ path: `${outDir}/${name}-desktop.png`, fullPage: true });

  await page.emulate(KnownDevices["iPhone 15"]);
  await page.goto(base + urlPath, { waitUntil: "networkidle0" });
  await page.screenshot({ path: `${outDir}/${name}-iphone.png`, fullPage: true });
  const m = await page.evaluate(() => ({
    vw: window.innerWidth,
    sw: document.documentElement.scrollWidth,
    wide: [...document.querySelectorAll("body *")]
      .filter((e) => e.getBoundingClientRect().right > window.innerWidth + 1)
      .slice(0, 5)
      .map((e) => e.tagName.toLowerCase() + (e.className ? "." + e.className : "")),
    broken: [...document.images].filter((i) => !i.complete || i.naturalWidth === 0).map((i) => i.src),
  }));
  console.log(`${urlPath}: iPhone 15 viewport ${m.vw}px, scrollWidth ${m.sw}px`);
  if (m.vw !== 393) failures.push(`${urlPath}: iPhone 15 emulation not applied (viewport ${m.vw}px)`);
  if (m.sw > m.vw) failures.push(`${urlPath}: scrolls sideways on iPhone 15 (${m.sw}px > ${m.vw}px): ${m.wide.join(", ")}`);
  for (const src of m.broken) failures.push(`${urlPath}: image did not load: ${src}`);
  await page.close();
}
await browser.close();
if (failures.length) {
  console.log(failures.join("\n"));
  process.exit(1);
}
console.log(`screenshots: ${posts.length} post(s) OK`);
