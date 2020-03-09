const {expect} = require('chai');
const Pageres = require('pageres');
const WIDTH = 1024;
const HEIGHT = 768;
const RESOLUTION = `${WIDTH}x${HEIGHT}`;
const PNG = require('pngjs').PNG;
const fs = require('fs');
const pixelmatch = require('pixelmatch');

const SCREENSHOT_FILENAME_TEMPLATE = 'new!localhost:8080!<%= width %>x<%= height %>';
const OLD_SCREENSHOT_PATH = `${__dirname}/fixtures/localhost:8080!${RESOLUTION}.png`;
const OLD_SCREENSHOT_PATH_COPIED = `${__dirname}/artifacts/old!localhost:8080!${RESOLUTION}.png`;
const NEW_SCREENSHOT_PATH = `${__dirname}/artifacts/new!localhost:8080!${RESOLUTION}.png`;
const SCREENSHOT_DIFF_PATH = `${__dirname}/artifacts/diff!localhost:8080!${RESOLUTION}.png`;

describe("xpra", function () {
  var new_img;
  var old_img;

  before(async function () {
    this.timeout(15000);
    old_img = PNG.sync.read(fs.readFileSync(OLD_SCREENSHOT_PATH));
    let new_img_raw = await new Pageres({ filename: SCREENSHOT_FILENAME_TEMPLATE })
      .src('http://localhost:8080/?sound=&floating_menu=&swap_keys=', [RESOLUTION])
      .dest(`${__dirname}/artifacts`)
      .run();
    new_img = PNG.sync.read(new_img_raw[0]);
    return new_img;
  });

  it("should produce an near equivalent 1024x768 screenshot showing an RXVT terminal on an oterwise blank desktop.", async function () {
    const { width, height } = old_img;
    const diff = new PNG({width, height});
    let difference = pixelmatch(old_img.data, new_img.data, diff.data, width, height, {threshold: 0.1});
    fs.writeFileSync(SCREENSHOT_DIFF_PATH, PNG.sync.write(diff));
    expect(difference).to.be.equal(0);
    return;
  })

  after(async function () {
    return fs.writeFileSync(OLD_SCREENSHOT_PATH_COPIED, PNG.sync.write(old_img));
  });
})
