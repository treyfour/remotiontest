import React from "react";
import { spring, useCurrentFrame, useVideoConfig } from "remotion";

interface ButtonProps {
  label: string;
  isHighlighted?: boolean;
  isClicked?: boolean;
  clickFrame?: number;
}

export const Button: React.FC<ButtonProps> = ({
  label,
  isHighlighted = false,
  isClicked = false,
  clickFrame = 0,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const clickProgress = spring({
    frame: isClicked ? frame - clickFrame : 0,
    fps,
    config: { damping: 10, stiffness: 300 },
  });

  const scale = isClicked ? 1 - clickProgress * 0.1 + clickProgress * 0.1 : 1;

  return (
    <div
      style={{
        marginTop: "24px",
        display: "flex",
        justifyContent: "flex-end",
      }}
    >
      <div
        style={{
          padding: "14px 28px",
          backgroundColor: isHighlighted ? "#8B5CF6" : "#7C3AED",
          borderRadius: "12px",
          color: "white",
          fontSize: "16px",
          fontWeight: 600,
          fontFamily: "system-ui, sans-serif",
          cursor: "pointer",
          transform: `scale(${scale})`,
          boxShadow: isHighlighted
            ? "0 8px 24px rgba(139, 92, 246, 0.5)"
            : "0 4px 12px rgba(139, 92, 246, 0.3)",
          transition: "box-shadow 0.2s ease",
        }}
      >
        {label}
      </div>
    </div>
  );
};
