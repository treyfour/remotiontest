# Remotion Animation Guide

Common animation patterns and techniques for Remotion.

## Core Animation APIs

### interpolate()
Linear interpolation between values based on frame.

```tsx
import { interpolate, useCurrentFrame } from "remotion";

const frame = useCurrentFrame();

// Fade in over 30 frames
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
});

// Move from left to center
const x = interpolate(frame, [0, 60], [-200, 0]);
```

### spring()
Physics-based spring animations.

```tsx
import { spring, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const scale = spring({
  frame,
  fps,
  config: {
    damping: 10,
    stiffness: 100,
    mass: 1,
  },
});
```

### Easing
Apply easing functions to interpolate.

```tsx
import { interpolate, Easing } from "remotion";

const value = interpolate(frame, [0, 30], [0, 1], {
  easing: Easing.bezier(0.25, 0.1, 0.25, 1),
});
```

## Common Patterns

### Staggered animations
```tsx
const items = ["A", "B", "C"];
const staggerDelay = 10;

{items.map((item, i) => {
  const delay = i * staggerDelay;
  const opacity = interpolate(frame, [delay, delay + 20], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return <div key={item} style={{ opacity }}>{item}</div>;
})}
```

### Loop animation
```tsx
const loop = (frame % 60) / 60; // 0 to 1 every 2 seconds at 30fps
const rotation = loop * 360;
```

### Sequence timing
```tsx
import { Sequence } from "remotion";

<>
  <Sequence from={0} durationInFrames={60}>
    <IntroScene />
  </Sequence>
  <Sequence from={60} durationInFrames={90}>
    <MainContent />
  </Sequence>
  <Sequence from={150}>
    <OutroScene />
  </Sequence>
</>
```

## Useful Components

- `<AbsoluteFill>` - Full-screen positioned container
- `<Sequence>` - Time-based component mounting
- `<Series>` - Sequential playback helper
- `<Loop>` - Loop a section
- `<Freeze>` - Freeze at a specific frame
- `<OffthreadVideo>` - Efficient video playback
- `<Audio>` - Audio playback with volume control
- `<Img>` - Optimized image loading
