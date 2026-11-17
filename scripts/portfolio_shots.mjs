// Portfolio screenshots of the light and dark themes.
// Captures key pages in both themes on desktop (1440x900 @2x) and mobile
// (390x844 @3x), a side-by-side light/dark composite of the home page, and a
// short MP4 of the theme toggle switching (needs ffmpeg on PATH).
//
// Usage:
//   swift run -c release igor1309dev
//   (cd Output && python3 -m http.server 8123 &)
//   node scripts/portfolio_shots.mjs http://localhost:8123 portfolio-shots [--no-clip]
//
// Output names: <page>-<viewport>-<theme>.png, home-desktop-composite.png,
// theme-toggle.mp4.
import puppeteer from "puppeteer";
import fs from "node:fs";
import path from "node:path";

const args = process.argv.slice(2);
const noClip = args.includes("--no-clip");
const [base = "http://localhost:8123", outDir = "portfolio-shots"] = args.filter((a) => !a.startsWith("--"));

export const PAGES = {
  home: "/",
  articles: "/articles/",
  post: "/articles/2026/2026-08-29-foliotell-a-speech-synthesizer-behind-a-reducer/",
  about: "/about/",
};
export const VIEWPORTS = {
  desktop: { width: 1440, height: 900, deviceScaleFactor: 2 },
  mobile: { width: 390, height: 844, deviceScaleFactor: 3, isMobile: true, hasTouch: true },
};
const THEMES = ["light", "dark"];

// Hide scrollbars and freeze animations so light/dark pairs match pixel for pixel.
const CLEAN_CSS = `
  html { scrollbar-width: none; }
  ::-webkit-scrollbar { display: none; }
  *, *::before, *::after { transition: none !important; animation: none !important; caret-color: transparent !important; }
`;

fs.mkdirSync(outDir, { recursive: true });
const browser = await puppeteer.launch({ args: ["--no-sandbox", "--hide-scrollbars"] });
const failures = [];

async function open(viewport, theme, urlPath) {
  const page = await browser.newPage();
  await page.setViewport(viewport);
  // The site's own pre-paint script reads localStorage['theme'].
  await page.evaluateOnNewDocument((t) => localStorage.setItem("theme", t), theme);
  await page.emulateMediaFeatures([{ name: "prefers-color-scheme", value: theme }]);
  const res = await page.goto(base + urlPath, { waitUntil: "networkidle0" });
  if (!res || !res.ok()) failures.push(`${urlPath}: HTTP ${res && res.status()}`);
  await page.addStyleTag({ content: CLEAN_CSS });
  await page.evaluate(() => document.fonts.ready);
  const applied = await page.evaluate(() => document.documentElement.getAttribute("data-theme"));
  if (applied !== theme) failures.push(`${urlPath}: theme ${theme} not applied (data-theme=${applied})`);
  return page;
}

for (const [name, urlPath] of Object.entries(PAGES)) {
  for (const [vp, viewport] of Object.entries(VIEWPORTS)) {
    for (const theme of THEMES) {
      const page = await open(viewport, theme, urlPath);
      // The post is here for its code blocks: frame the first one.
      if (name === "post") {
        const found = await page.evaluate(() => {
          const pre = document.querySelector("article pre, pre");
          if (!pre) return false;
          window.scrollTo(0, pre.getBoundingClientRect().top + window.scrollY - 160);
          return true;
        });
        if (!found) failures.push(`${urlPath}: no code block to frame`);
      }
      const file = path.join(outDir, `${name}-${vp}-${theme}.png`);
      // Viewport-sized (above the fold) so every pair has identical dimensions.
      await page.screenshot({ path: file });
      console.log(file);
      await page.close();
    }
  }
}

// Side-by-side composite of the home page on desktop.
{
  const img = (t) => "data:image/png;base64," + fs.readFileSync(path.join(outDir, `home-desktop-${t}.png`)).toString("base64");
  const page = await browser.newPage();
  await page.setViewport({ width: 2 * 1440 + 3 * 48, height: 900 + 2 * 48 + 40, deviceScaleFactor: 2 });
  await page.setContent(`<!doctype html><style>
    body { margin: 0; padding: 48px; display: flex; gap: 48px; background: linear-gradient(90deg, #e9e9ee 50%, #15161a 50%); font: 500 22px -apple-system, system-ui, sans-serif; }
    figure { margin: 0; } img { width: 1440px; height: 900px; display: block; border-radius: 14px; box-shadow: 0 12px 40px rgba(0,0,0,.35); }
    figcaption { margin-top: 14px; text-align: center; } .l { color: #333; } .d { color: #ddd; }
  </style><figure><img src="${img("light")}"><figcaption class="l">Light</figcaption></figure><figure><img src="${img("dark")}"><figcaption class="d">Dark</figcaption></figure>`);
  await page.evaluate(() => Promise.all([...document.images].map((i) => i.decode())));
  const file = path.join(outDir, "home-desktop-composite.png");
  await page.screenshot({ path: file });
  console.log(file);
  await page.close();
}

// Theme toggle clip: start in light (system = light), click through Light -> Dark -> System.
if (!noClip) {
  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900, deviceScaleFactor: 1 });
  await page.emulateMediaFeatures([{ name: "prefers-color-scheme", value: "light" }]);
  await page.evaluateOnNewDocument(() => localStorage.removeItem("theme"));
  await page.goto(base + "/", { waitUntil: "networkidle0" });
  await page.addStyleTag({ content: "html { scrollbar-width: none; } ::-webkit-scrollbar { display: none; }" });
  // The header may hold more than one toggle (one per layout); use the visible one.
  let toggle, box;
  for (const b of await page.$$(".theme-toggle")) {
    const bb = await b.boundingBox();
    if (bb && bb.width > 0) { toggle = b; box = bb; break; }
  }
  if (!toggle) throw new Error("no visible .theme-toggle on the home page");
  await page.mouse.move(box.x - 200, box.y + 200);
  const file = path.join(outDir, "theme-toggle.mp4");
  const recorder = await page.screencast({ path: file, format: "mp4", fps: 30 });
  const pause = (ms) => new Promise((r) => setTimeout(r, ms));
  await pause(1200);
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 20 });
  for (let i = 0; i < 3; i++) {
    await pause(500);
    await toggle.click();
    await pause(1300);
  }
  await recorder.stop();
  const finalTheme = await page.evaluate(() => localStorage.getItem("theme"));
  if (finalTheme !== null) failures.push(`toggle: expected to cycle back to system, got ${finalTheme}`);
  console.log(file);
  await page.close();
}

await browser.close();
if (failures.length) {
  console.log(failures.join("\n"));
  process.exit(1);
}
console.log(`portfolio shots: OK -> ${outDir}`);
