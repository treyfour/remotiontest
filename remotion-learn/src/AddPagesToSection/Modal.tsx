import React from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig, Easing } from "remotion";

interface ModalProps {
  isOpen: boolean;
  openFrame: number;
  closeFrame?: number;
  children: React.ReactNode;
}

export const Modal: React.FC<ModalProps> = ({
  isOpen,
  openFrame,
  closeFrame = 125,
  children
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Opening animation
  const openProgress = spring({
    frame: frame - openFrame,
    fps,
    config: {
      damping: 20,
      stiffness: 150,
    },
  });

  // Closing animation - fast 3-frame fade out to match other transitions
  const closeProgress = interpolate(
    frame,
    [closeFrame, closeFrame + 3],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.ease) }
  );

  // Combine open and close
  const effectiveProgress = Math.min(openProgress, 1 - closeProgress);

  const opacity = interpolate(effectiveProgress, [0, 1], [0, 1]);
  const scale = interpolate(effectiveProgress, [0, 1], [0.95, 1]);
  const translateY = interpolate(effectiveProgress, [0, 1], [20, 0]);

  // Don't render if fully closed
  if (frame < openFrame || (frame > closeFrame + 3 && effectiveProgress < 0.01)) return null;

  return (
    <>
      {/* Backdrop - subtle blur only, no color change */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          backdropFilter: `blur(${opacity * 2}px)`,
        }}
      />
      {/* Modal */}
      <div
        style={{
          position: "absolute",
          left: "50%",
          top: "50%",
          transform: `translate(-50%, -50%) scale(${scale}) translateY(${translateY}px)`,
          opacity,
          backgroundColor: "#FFFFFF",
          borderRadius: "24px",
          padding: "32px",
          boxShadow: `0 25px 50px -12px rgba(139, 92, 246, ${0.25 * opacity})`,
          border: "1px solid #EDE9FE",
        }}
      >
        {children}
      </div>
    </>
  );
};
