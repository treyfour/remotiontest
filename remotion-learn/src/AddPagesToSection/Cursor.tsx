import React from "react";
import { useCurrentFrame } from "remotion";

interface CursorProps {
  x: number;
  y: number;
  isClicking?: boolean;
}

export const Cursor: React.FC<CursorProps> = ({ x, y, isClicking = false }) => {
  const frame = useCurrentFrame();

  // Subtle floating animation
  const float = Math.sin(frame * 0.1) * 2;

  // Click scale animation
  const scale = isClicking ? 0.9 : 1;

  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y + float,
        transform: `scale(${scale})`,
        transition: "transform 0.1s ease-out",
        zIndex: 1000,
        pointerEvents: "none",
      }}
    >
      {/* Traditional arrow cursor */}
      <svg width="24" height="36" viewBox="0 0 24 36" fill="none">
        <path
          d="M2 2L2 28L8.5 21.5L13 32L17 30L12.5 19.5L22 19.5L2 2Z"
          fill="#000000"
          stroke="#FFFFFF"
          strokeWidth="2"
          strokeLinejoin="round"
        />
      </svg>
    </div>
  );
};
