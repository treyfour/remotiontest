import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
  Easing,
} from "remotion";
import { z } from "zod";
import { CarbonTextInput } from "./CarbonInput/CarbonTextInput";

export const carbonInputDemoSchema = z.object({
  label: z.string(),
  placeholder: z.string(),
  helperText: z.string(),
  typedText: z.string(),
  typingSpeed: z.number().default(3), // frames per character
});

export const CarbonInputDemo: React.FC<z.infer<typeof carbonInputDemoSchema>> = ({
  label,
  placeholder,
  helperText,
  typedText,
  typingSpeed,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Timeline (at 30fps):
  // 0-15 frames (0-0.5s): Fade in
  // 15-30 frames (0.5-1s): Focus animation
  // 30+ frames: Typing begins

  const FADE_IN_END = 15;
  const FOCUS_START = 15;
  const FOCUS_END = 30;
  const TYPING_START = 30;

  // Fade in animation
  const fadeIn = interpolate(frame, [0, FADE_IN_END], [0, 1], {
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.ease),
  });

  // Focus state (true after focus animation completes)
  const isFocused = frame >= FOCUS_START;

  // Calculate how many characters to show
  const typingFrame = Math.max(0, frame - TYPING_START);
  const charactersToShow = Math.min(
    Math.floor(typingFrame / typingSpeed),
    typedText.length
  );
  const currentValue = typedText.slice(0, charactersToShow);

  // Cursor blink (visible every 15 frames = 0.5s at 30fps)
  const cursorVisible = frame >= TYPING_START && Math.floor(frame / 15) % 2 === 0;

  // Only show cursor while typing or shortly after
  const isTypingComplete = charactersToShow >= typedText.length;
  const showCursor = !isTypingComplete || (isTypingComplete && frame < TYPING_START + typedText.length * typingSpeed + 30);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#ffffff",
        justifyContent: "center",
        alignItems: "center",
        padding: "0 200px",
      }}
    >
      {/* IBM Plex Sans font import */}
      <style>
        {`@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600&display=swap');`}
      </style>

      <div style={{ opacity: fadeIn, width: "100%", maxWidth: "900px" }}>
        <CarbonTextInput
          label={label}
          placeholder={placeholder}
          helperText={helperText}
          value={currentValue}
          isFocused={isFocused}
          showCursor={showCursor && cursorVisible}
        />
      </div>
    </AbsoluteFill>
  );
};
