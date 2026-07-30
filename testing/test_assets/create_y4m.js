const fs = require('fs');
const path = require('path');

function generateY4M() {
  const assetsDir = path.resolve(__dirname);
  if (!fs.existsSync(assetsDir)) {
    fs.mkdirSync(assetsDir, { recursive: true });
  }
  const outputPath = path.join(assetsDir, 'sample_video.y4m');

  const width = 320;
  const height = 240;
  const numFrames = 30;

  const header = `YUV4MPEG2 W${width} H${height} F30:1 Ip A1:1 C420jpeg\n`;
  const frameHeader = `FRAME\n`;

  const ySize = width * height;
  const uSize = (width / 2) * (height / 2);
  const vSize = (width / 2) * (height / 2);
  const frameDataSize = ySize + uSize + vSize;

  const buffer = Buffer.alloc(
    header.length + numFrames * (frameHeader.length + frameDataSize)
  );

  let offset = 0;
  buffer.write(header, offset, 'ascii');
  offset += header.length;

  for (let f = 0; f < numFrames; f++) {
    buffer.write(frameHeader, offset, 'ascii');
    offset += frameHeader.length;

    // Fill Y plane with neutral light gray (value 160)
    buffer.fill(160, offset, offset + ySize);
    offset += ySize;

    // Fill U plane with neutral 128
    buffer.fill(128, offset, offset + uSize);
    offset += uSize;

    // Fill V plane with neutral 128
    buffer.fill(128, offset, offset + vSize);
    offset += vSize;
  }

  fs.writeFileSync(outputPath, buffer);
  console.log(`[Y4M Generator] Created fake video sample at: ${outputPath} (${buffer.length} bytes)`);
  return outputPath;
}

if (require.main === module) {
  generateY4M();
}

module.exports = generateY4M;
