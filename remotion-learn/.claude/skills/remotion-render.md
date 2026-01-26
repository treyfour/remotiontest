# Remotion Video Renderer

Render Remotion compositions to video files.

## Usage
When the user asks to render a video, use these commands:

### Open Remotion Studio (interactive preview)
```bash
npm run remotion:studio
```

### Render to MP4
```bash
npx remotion render remotion/index.ts <CompositionId> out/video.mp4
```

### Render Options

**Output formats:**
- MP4: `out/video.mp4` (default, requires FFmpeg)
- WebM: `out/video.webm`
- GIF: `out/video.gif`
- PNG sequence: `out/frames/` (with `--image-format png`)

**Quality options:**
- `--crf 18` - quality (0-51, lower is better)
- `--codec h264` - video codec (h264, h265, vp8, vp9)
- `--scale 0.5` - render at half resolution

**Frame range:**
- `--frames 0-60` - render specific frames

### Example Commands

Render specific composition:
```bash
npx remotion render remotion/index.ts MyComposition out/my-video.mp4
```

Render as GIF:
```bash
npx remotion render remotion/index.ts MyComposition out/animation.gif
```

High quality render:
```bash
npx remotion render remotion/index.ts MyComposition out/video.mp4 --crf 10
```

### Prerequisites
- FFmpeg must be installed for video rendering
- Install with: `brew install ffmpeg` (macOS) or download from ffmpeg.org
