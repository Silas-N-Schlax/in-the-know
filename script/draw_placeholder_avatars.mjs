// Placeholder avatar art. Run: node script/draw_placeholder_avatars.mjs
// Replace any PNG in app/assets/images/avatars with your own art whenever you like.
// Draws each avatar as a flat, geometric animal face (SVG) and rasterizes it to a transparent 512px PNG.
import { chromium } from 'playwright'
import { writeFileSync, mkdirSync } from 'node:fs'

const OUT = process.argv[2] || 'app/assets/images/avatars'
mkdirSync(OUT, { recursive: true })

const INK = '#1d1b3a'
const eyes = (y = 50, dx = 13, r = 5, color = INK) =>
  `<circle cx="${50 - dx}" cy="${y}" r="${r}" fill="${color}"/><circle cx="${50 + dx}" cy="${y}" r="${r}" fill="${color}"/>` +
  `<circle cx="${50 - dx + r * 0.35}" cy="${y - r * 0.35}" r="${r * 0.32}" fill="#fff"/><circle cx="${50 + dx + r * 0.35}" cy="${y - r * 0.35}" r="${r * 0.32}" fill="#fff"/>`
const cheeks = (y = 60, color = '#ff8fb1') =>
  `<ellipse cx="28" cy="${y}" rx="5" ry="3" fill="${color}" opacity=".55"/><ellipse cx="72" cy="${y}" rx="5" ry="3" fill="${color}" opacity=".55"/>`
const smile = (y = 64, w = 6) => `<path d="M${50 - w} ${y} q${w} ${w * 0.8} ${w * 2} 0" fill="none" stroke="${INK}" stroke-width="2.4" stroke-linecap="round"/>`
const nose = (y = 58, color = INK, rx = 4, ry = 3) => `<ellipse cx="50" cy="${y}" rx="${rx}" ry="${ry}" fill="${color}"/>`
const head = (color, rx = 34, ry = 32, cy = 54) => `<ellipse cx="50" cy="${cy}" rx="${rx}" ry="${ry}" fill="${color}"/>`
const roundEars = (color, inner, y = 26, dx = 25, r = 11) =>
  `<circle cx="${50 - dx}" cy="${y}" r="${r}" fill="${color}"/><circle cx="${50 + dx}" cy="${y}" r="${r}" fill="${color}"/>` +
  (inner ? `<circle cx="${50 - dx}" cy="${y}" r="${r * 0.55}" fill="${inner}"/><circle cx="${50 + dx}" cy="${y}" r="${r * 0.55}" fill="${inner}"/>` : '')
const pointEars = (color, inner, spread = 24, top = 10) =>
  `<path d="M${50 - spread - 12} 40 L${50 - spread} ${top} L${50 - spread + 12} 34 Z" fill="${color}"/><path d="M${50 + spread + 12} 40 L${50 + spread} ${top} L${50 + spread - 12} 34 Z" fill="${color}"/>` +
  (inner ? `<path d="M${50 - spread - 6} 36 L${50 - spread} ${top + 9} L${50 - spread + 6} 34 Z" fill="${inner}"/><path d="M${50 + spread + 6} 36 L${50 + spread} ${top + 9} L${50 + spread - 6} 34 Z" fill="${inner}"/>` : '')

const animals = {
  otter: () => roundEars('#8a5a3b', '#5e3a24', 30, 27, 8) + head('#9c6a47') + `<ellipse cx="50" cy="64" rx="18" ry="13" fill="#e9d2b4"/>` + eyes(50, 13) + nose(58) + `<path d="M36 62h-10M36 66h-9M64 62h10M64 66h9" stroke="${INK}" stroke-width="1.5" stroke-linecap="round"/>` + smile(66, 4),
  fox: () => pointEars('#e8742c', '#2b1d1a', 22, 8) + head('#ee8034', 34, 30) + `<path d="M20 58 Q32 80 50 82 Q68 80 80 58 Q66 70 50 70 Q34 70 20 58Z" fill="#fff4e8"/>` + eyes(50, 14, 4.5) + nose(63, INK, 4, 3) + smile(68, 4),
  axolotl: () => `<g fill="#ff7aa8">${[-1, 1].map((s) => [0, 1, 2].map((i) => `<ellipse cx="${50 + s * (34 + i * 3)}" cy="${38 + i * 12}" rx="10" ry="4" transform="rotate(${s * (i * 22 - 22)} ${50 + s * (34 + i * 3)} ${38 + i * 12})"/>`).join('')).join('')}</g>` + head('#ffc2d6', 34, 28, 56) + eyes(52, 16, 4.5) + smile(64, 8) + cheeks(62),
  capybara: () => roundEars('#8b6a45', null, 24, 22, 6) + `<rect x="18" y="26" width="64" height="62" rx="26" fill="#a47e55"/>` + `<rect x="30" y="56" width="40" height="30" rx="14" fill="#8b6a45"/>` + eyes(46, 14, 3.5) + `<ellipse cx="43" cy="66" rx="2.5" ry="2" fill="${INK}"/><ellipse cx="57" cy="66" rx="2.5" ry="2" fill="${INK}"/>`,
  penguin: () => head('#23263a', 34, 34) + `<path d="M50 34 C30 34 24 54 26 70 C30 86 70 86 74 70 C76 54 70 34 50 34Z" fill="#fff"/>` + eyes(52, 11, 4.5) + `<path d="M44 60 L56 60 L50 69Z" fill="#f6a31b"/>`,
  frog: () => `<circle cx="32" cy="32" r="14" fill="#5cb85c"/><circle cx="68" cy="32" r="14" fill="#5cb85c"/>` + head('#5cb85c', 36, 28, 60) + `<circle cx="32" cy="32" r="8" fill="#fff"/><circle cx="68" cy="32" r="8" fill="#fff"/><circle cx="33" cy="33" r="4.5" fill="${INK}"/><circle cx="67" cy="33" r="4.5" fill="${INK}"/>` + `<path d="M30 66 q20 14 40 0" fill="none" stroke="${INK}" stroke-width="2.6" stroke-linecap="round"/>` + cheeks(64),
  owl: () => `<path d="M18 22 L34 34 L22 44Z M82 22 L66 34 L78 44Z" fill="#7a5230"/>` + head('#946238', 34, 34) + `<circle cx="36" cy="50" r="13" fill="#f3e2c0"/><circle cx="64" cy="50" r="13" fill="#f3e2c0"/>` + eyes(50, 14, 6) + `<path d="M45 58 L55 58 L50 68Z" fill="#f6a31b"/>` + `<path d="M36 76 q4 4 8 0 M48 78 q4 4 8 0 M58 76 q4 4 8 0" fill="none" stroke="#7a5230" stroke-width="2"/>`,
  hedgehog: () => `<g fill="#6b4a33">${Array.from({ length: 11 }, (_, i) => { const a = Math.PI * (0.95 + i * 0.11); const x = 50 + Math.cos(a) * 40; const y = 56 + Math.sin(a) * 40; return `<path d="M${50 + Math.cos(a - 0.14) * 28} ${56 + Math.sin(a - 0.14) * 28} L${x} ${y} L${50 + Math.cos(a + 0.14) * 28} ${56 + Math.sin(a + 0.14) * 28}Z"/>` }).join('')}</g>` + head('#6b4a33', 32, 30, 56) + `<ellipse cx="50" cy="64" rx="22" ry="18" fill="#e9c9a0"/>` + eyes(56, 11, 3.8) + nose(66, INK, 4, 3) + cheeks(66),
  llama: () => `<rect x="30" y="8" width="9" height="26" rx="4.5" fill="#efe3cf"/><rect x="61" y="8" width="9" height="26" rx="4.5" fill="#efe3cf"/>` + `<rect x="24" y="24" width="52" height="64" rx="24" fill="#f4ead8"/>` + `<ellipse cx="50" cy="30" rx="18" ry="9" fill="#e6d5b8"/>` + eyes(50, 12, 4) + `<ellipse cx="50" cy="70" rx="14" ry="10" fill="#e6d5b8"/>` + `<path d="M46 70 q4 4 8 0" fill="none" stroke="${INK}" stroke-width="2" stroke-linecap="round"/>`,
  octopus: () => `<g fill="#9b59d0">${[0, 1, 2, 3, 4].map((i) => `<rect x="${18 + i * 14}" y="62" width="10" height="28" rx="5"/>`).join('')}</g>` + head('#a867dc', 32, 30, 46) + eyes(46, 12, 5) + smile(58, 5) + cheeks(56),
  flamingo: () => `<ellipse cx="50" cy="52" rx="30" ry="32" fill="#ff8fb8"/>` + `<path d="M54 56 C80 56 84 70 74 82 L68 76 C72 70 68 66 56 66Z" fill="#f3f3f3"/><path d="M68 76 L74 82 L66 88 Z" fill="${INK}"/>` + `<circle cx="42" cy="46" r="5" fill="${INK}"/><circle cx="43.8" cy="44.2" r="1.6" fill="#fff"/>` + cheeks(58),
  sloth: () => head('#a08a6c', 36, 34) + `<ellipse cx="50" cy="56" rx="28" ry="22" fill="#e8dcc6"/>` + `<path d="M24 50 Q34 42 44 52 Q34 58 24 50Z M76 50 Q66 42 56 52 Q66 58 76 50Z" fill="#6e5a43"/>` + `<circle cx="36" cy="51" r="3.6" fill="${INK}"/><circle cx="64" cy="51" r="3.6" fill="${INK}"/>` + nose(60, INK, 4.5, 3) + smile(66, 6),
  walrus: () => head('#9a6f58', 36, 32) + eyes(44, 14, 4) + `<ellipse cx="41" cy="62" rx="11" ry="9" fill="#c79d82"/><ellipse cx="59" cy="62" rx="11" ry="9" fill="#c79d82"/>` + nose(56, INK, 5, 3.5) + `<path d="M42 68 L40 90 L46 70Z M58 68 L60 90 L54 70Z" fill="#fffaf0"/>`,
  koala: () => roundEars('#9aa3ad', '#f1d9e4', 32, 30, 15) + head('#a8b1bb', 32, 32) + eyes(50, 13, 4) + `<ellipse cx="50" cy="60" rx="8" ry="11" fill="#3a3a48"/>` + cheeks(64),
  narwhal: () => `<path d="M50 4 L55 28 L45 28Z" fill="#f2ecd8"/><path d="M47 10 L53 12 M46 16 L54 18 M46 22 L54 24" stroke="#c9bfa0" stroke-width="1.4"/>` + head('#6fa9c9', 34, 32, 58) + `<ellipse cx="50" cy="72" rx="24" ry="12" fill="#cfe4ef"/>` + eyes(54, 14, 4) + smile(66, 5) + cheeks(64),
  platypus: () => head('#7a5b44', 34, 30, 44) + eyes(40, 13, 4) + `<rect x="24" y="56" width="52" height="30" rx="15" fill="#3d3a44"/><ellipse cx="44" cy="64" rx="2" ry="1.5" fill="#8e8a99"/><ellipse cx="56" cy="64" rx="2" ry="1.5" fill="#8e8a99"/>`,
  red_panda: () => pointEars('#c8502b', '#fff4e8', 24, 14) + head('#d25b2e', 34, 30) + `<path d="M22 50 Q30 72 46 70 L40 56Z M78 50 Q70 72 54 70 L60 56Z" fill="#fff4e8"/>` + `<ellipse cx="50" cy="66" rx="10" ry="7" fill="#fff4e8"/>` + `<path d="M26 58 q8 6 14 2 M74 58 q-8 6 -14 2" stroke="#7c2d18" stroke-width="3" fill="none" stroke-linecap="round"/>` + eyes(50, 13, 4) + nose(62, INK, 3.5, 2.5),
  goose: () => `<ellipse cx="50" cy="54" rx="30" ry="34" fill="#f7f7f2"/>` + `<path d="M46 58 L78 56 Q80 64 72 66 L46 66Z" fill="#f59e1b"/>` + `<circle cx="42" cy="46" r="4.5" fill="${INK}"/><circle cx="43.5" cy="44.5" r="1.4" fill="#fff"/>` + `<path d="M34 38 L48 42" stroke="${INK}" stroke-width="2.6" stroke-linecap="round"/>`,
  shark: () => `<path d="M50 6 L64 30 L38 30Z" fill="#6c86a3"/>` + head('#7d97b4', 36, 32, 56) + `<path d="M22 62 Q50 92 78 62 Q50 72 22 62Z" fill="#eef3f8"/>` + `<path d="M34 66 l4 5 4-5 4 5 4-5 4 5 4-5 4 5" fill="none" stroke="${INK}" stroke-width="1.6" stroke-linejoin="round"/>` + eyes(48, 16, 4) + `<path d="M22 50 l4 -3 M22 55 l4 -3" stroke="#56708c" stroke-width="2" stroke-linecap="round"/>`,
  toucan: () => `<ellipse cx="44" cy="54" rx="30" ry="34" fill="#1f2230"/>` + `<ellipse cx="38" cy="40" rx="11" ry="9" fill="#f7f1d8"/>` + `<circle cx="38" cy="40" r="4.5" fill="${INK}"/><circle cx="39.6" cy="38.4" r="1.4" fill="#fff"/>` + `<path d="M48 44 Q84 38 94 56 Q80 70 48 62Z" fill="#f7a21b"/><path d="M52 58 Q76 62 92 58 Q80 70 50 62Z" fill="#e8472c"/><path d="M84 44 Q92 48 94 56 L86 54Z" fill="#1f2230"/>`,
  raccoon: () => pointEars('#8c8c96', '#3a3a44', 24, 14) + head('#9d9da8', 34, 30) + `<path d="M18 52 Q30 40 46 50 Q50 54 54 50 Q70 40 82 52 Q70 62 54 56 Q50 54 46 56 Q30 62 18 52Z" fill="#2b2b35"/>` + `<ellipse cx="50" cy="68" rx="14" ry="10" fill="#f1f1f4"/>` + eyes(51, 14, 4, '#f7f7f7').replaceAll('#fff"', '#2b2b35"') + nose(64, INK, 4, 3) + `<circle cx="36" cy="51" r="2.6" fill="${INK}"/><circle cx="64" cy="51" r="2.6" fill="${INK}"/>`,
}

const browser = await chromium.launch()
const page = await browser.newPage({ viewport: { width: 512, height: 512 } })
for (const [name, draw] of Object.entries(animals)) {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="512" height="512">${draw()}</svg>`
  await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`)
  await page.screenshot({ path: `${OUT}/${name}.png`, omitBackground: true, clip: { x: 0, y: 0, width: 512, height: 512 } })
  writeFileSync(`${OUT}/../svg-${name}.svg`, svg)
  console.log('drew', name)
}
await browser.close()
