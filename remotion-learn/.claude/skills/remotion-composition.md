# Remotion Composition Creator

Create new Remotion video compositions with animations and effects.

## Usage
When the user asks to create a new video composition or scene, follow these steps:

1. Create a new component file in `remotion/` directory
2. Use Remotion's core APIs:
   - `useCurrentFrame()` - get current frame number
   - `useVideoConfig()` - get fps, width, height, durationInFrames
   - `interpolate()` - create smooth animations
   - `spring()` - physics-based animations
   - `AbsoluteFill` - full-screen container
   - `Sequence` - time-based sequencing of elements

3. Register the composition in `remotion/Root.tsx`

## Example Composition Structure

```tsx
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Sequence,
} from "remotion";

export const MyScene: React.FC<{ text: string }> = ({ text }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ backgroundColor: "#000" }}>
      <Sequence from={0} durationInFrames={60}>
        <div style={{ opacity }}>{text}</div>
      </Sequence>
    </AbsoluteFill>
  );
};
```

## Registering in Root.tsx

```tsx
<Composition
  id="MyScene"
  component={MyScene}
  durationInFrames={150}
  fps={30}
  width={1920}
  height={1080}
  defaultProps={{ text: "Hello" }}
/>
```

## Common Animation Patterns

- Fade in: `interpolate(frame, [0, fps], [0, 1])`
- Slide in: `interpolate(frame, [0, 30], [-100, 0])`
- Scale up: `spring({ frame, fps, config: { damping: 10 } })`
- Rotate: `interpolate(frame, [0, fps], [0, 360])`
